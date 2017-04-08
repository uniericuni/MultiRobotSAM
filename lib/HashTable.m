classdef HashTable < handle
%--------------------------------------------------------------------------
% Class:        HashTable < handle
%               
% Constructor:  H = HashTable(m);
%               
% Properties:   (none)
%               
% Methods:               H.Add(key,value);
%                        H.Set(key,value);
%               value  = H.Get(key);
%                        H.Remove(key);
%               bool   = H.ContainsKey(key);
%               keys   = H.Keys();
%               values = H.Values();
%               he     = H.HashEfficiency();
%               count  = H.Count();
%               bool   = H.IsEmpty();
%                        H.Clear();
%               
% Indexing:     The following set/get indexing is supported:
%               
%               H(key) = value;
%               value  = H(value);
%               
% Description:  This class implements a hash table with alphanumeric
%               character keys and arbitrarily typed values. The
%               implementation employs list-based collision handling within
%               each hash bucket
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         January 16, 2014
%--------------------------------------------------------------------------

    %
    % Private properties
    %
    properties (Access = private)
        % Hash table storage
        k;                  % current number of key-value pairs
        
        % Hash table parameters
        m;                  % number of buckets
        
        % List pointers
        L = HashList();     % bucket list pointers
        
        % Hash function parameters
        p;                  % hash function parameter
        a;                  % hash function parameter
        b;                  % hash function parameter
        c;                  % hash function parameter
    end
    
    %
    % Public methods
    %
    methods (Access = public)
        %
        % Constructor
        %
        function this = HashTable(m)
            %----------------------- Constructor --------------------------
            % Syntax:       H = HashTable(m);
            %               
            % Inputs:       m is the desired number of hash buckets
            %               
            % Note:         The performance of hash tables degrades rapidly
            %               when the number of key-value pairs in them is
            %               significantly larger than the number of hash
            %               buckets
            %               
            % Description:  Creates an empty hash table with m buckets
            %--------------------------------------------------------------
            
            % Set bucket count
            this.m = m;
            
            % Start with empty hash table
            this.Clear();
            
            % Initialize hash function
            this.InitHashFunction();
        end
        
        %
        % Add element to hash table
        %
        function Add(this,key,value)
            %-------------------------- Add -------------------------------
            % Syntax:       H.Add(key,value);
            %               
            % Inputs:       key is an alphanumeric character array
            %               
            %               value is an arbitrary object
            %               
            % Description:  Inserts the given key-value pair into H
            %--------------------------------------------------------------
            
            % Compute hash code
            hk = this.HashCode(key);
            
            % Add element to hash structure 
            this.L(hk).Prepend(key,value);
            this.k = this.k + 1;
        end
        
        %
        % Define () for HashTable element assignment
        %
        % NOTE: MATLAB's deplorable implementation of subsasgn() makes this
        % method extremeley clunky...
        %
        function this = subsasgn(this,S,value)
            %------------------ ()-based assignment -----------------------
            % Syntax:       H(key) = value;
            %               
            % Inputs:       key is an alphanumeric character array
            %               
            %               value is an arbitrary object
            %               
            % Description:  Sets the value of the key-value pair in H with
            %               the given key
            %--------------------------------------------------------------
            
            switch S(1).type
                case '()'
                    % User is setting a HashTable element
                    key = S(1).subs{1};
                    this.Set(key,value);
                case '{}'
                    % {}-indexing is not supported 
                    HashTable.CellIndexingError();
                case '.'
                    if isprop(this,S(1).subs)
                        % User tried to set a property (assumed private)
                        HashTable.PrivatePropertySetError(S(1).subs);
                    else
                        % Call built-in assignment method
                        this = builtin('subsasgn',this,S,value);
                    end
            end
        end
        
        %
        % Set value of (last added) element with given key
        %
        function Set(this,key,value)
            %-------------------------- Set -------------------------------
            % Syntax:       H.Set(key,value);
            %               
            % Inputs:       key is an alphanumeric character array
            %               
            %               value is an arbitrary object
            %               
            % Description:  Sets the value of the key-value pair in H with
            %               the given key
            %--------------------------------------------------------------
            
            % Compute hash code
            hk = this.HashCode(key);
            
            % Find key in list
            x = this.L(hk).FindKey(key);
            if isnan(x)
                % Key not present in hash table
                HashTable.KeyNotFoundError(key);
            end
            x.value = value;
        end
        
        %
        % Define () for HashTable element referencing
        %
        % NOTE: MATLAB's deplorable implementation of subsref() makes this
        % method extremeley clunky...
        %
        function varargout = subsref(this,S)
            %------------------- ()-based reference -----------------------
            % Syntax:       value = H(key);
            %               
            % Inputs:       key is an alphanumeric character array
            %               
            % Outputs:      value is the object associated with the
            %               key-value pair in H with the given key
            %               
            % Description:  Returns the value of the key-value pair in H
            %               with the given key
            %--------------------------------------------------------------
            
            switch S(1).type
                case '()'
                    % User is getting a HashTable element
                    key = S(1).subs{1};
                    varargout{1} = this.Get(key);
                case '{}'
                    % {}-indexing is not supported
                    HashTable.CellIndexingError();
                case '.'
                    % Call built-in reference method
                    if (isprop(this,S(1).subs) || (nargout(['HashTable>HashTable.' S(1).subs]) > 0))
                        % Doesn't assign output args >= 2, if they exist
                        varargout{1} = builtin('subsref',this,S);
                    else
                        builtin('subsref',this,S);
                    end
            end
        end
        
        %
        % Get value of (last added) element with given key
        %
        function value = Get(this,key)
            %-------------------------- Get -------------------------------
            % Syntax:       value = H.Get(key);
            %               
            % Inputs:       key is an alphanumeric character array
            %               
            % Outputs:      value is the object associated with the
            %               key-value pair in H with the given key
            %               
            % Description:  Returns the value of the key-value pair in H
            %               with the given key
            %--------------------------------------------------------------
            
            % Compute hash code
            hk = this.HashCode(key);
            
            % Find key in list
            x = this.L(hk).FindKey(key);
            if isnan(x)
                % Key not present in hash table
                HashTable.KeyNotFoundError(key);
            end
            
            % Get value
            value = x.value;
        end
        
        %
        % Remove (last added) element with given key from hash table
        %
        function Remove(this,key)
            %------------------------- Remove -----------------------------
            % Syntax:       H.Remove(key);
            %               
            % Inputs:       key is an alphanumeric character array
            %               
            % Description:  Removes the key-value pair with the given key
            %               from H
            %--------------------------------------------------------------
            
            % Compute hash code
            hk = this.HashCode(key);
            
            % Remove key from list
            success = this.L(hk).Remove(key);
            if (success == false)
                % Key not present in hash table
                HashTable.KeyNotFoundError(key);
            end
            this.k = this.k - 1;
        end
        
        %
        % Search for (last added) element with given key
        %
        function bool = ContainsKey(this,key)
            %---------------------- ContainsKey ---------------------------
            % Syntax:       bool = H.ContainsKeys(key);
            %               
            % Inputs:       key is an alphanumeric character array
            %               
            % Outputs:      bool = {true,false}
            %               
            % Description:  Determines if H contains a key-value pair with
            %               the given key
            %--------------------------------------------------------------
            
            % Compute hash code
            hk = this.HashCode(key);
            
            % Search for key in list(hk)
            bool = ~isnan(this.L(hk).FindKey(key));
        end
        
        %
        % Return a cell array of all keys in the hash table
        %
        function keys = Keys(this)
            %-------------------------- Keys ------------------------------
            % Syntax:       keys = H.Keys();
            %               
            % Outputs:      keys is a cell array containing the keys in H
            %               
            % Description:  Returns all of the keys in H
            %--------------------------------------------------------------
            
            keys = cell(this.k,1);
            ii = 1;
            for jj = 1:this.m
                lenjj = this.L(jj).Count;
                if (lenjj > 0)
                    keys(ii:(ii + lenjj - 1)) = this.L(jj).Keys;
                    ii = ii + lenjj;
                end
            end
        end
        
        %
        % Return a cell array of all values in the hash table
        %
        function values = Values(this)
            %------------------------- Values -----------------------------
            % Syntax:       values = H.Values();
            %               
            % Outputs:      values is a cell array that contains the values
            %               in H
            %               
            % Description:  Returns all of the keys in H
            %--------------------------------------------------------------
            
            values = cell(this.k,1);
            ii = 1;
            for jj = 1:this.m
                lenjj = this.L(jj).Count;
                if (lenjj > 0)
                    values(ii:(ii + lenjj - 1)) = this.L(jj).Values;
                    ii = ii + lenjj;
                end
            end
        end
        
        %
        % Returns the hash efficiency, defined as the ratio of the number
        % of nonempty buckets to the number of elements in the hash table
        %
        function he = HashEfficiency(this)
            %--------------------- HashEfficiency -------------------------
            % Syntax:       he = H.HashEfficiency();
            %               
            % Outputs:      he is the hash efficiency of H
            %               
            % Description:  Returns the hash efficiency of H, defined as
            %               the ratio of the number of nonempty buckets to
            %               the number of key-value pairs in the hash table
            %--------------------------------------------------------------
            
            num = 0;
            for jj = 1:this.m
                num = num + ~this.L(jj).IsEmpty;
            end
            he = num / this.k;
        end
        
        %
        % Return number of elements in hash table
        %
        function count = Count(this)
            %-------------------------- Count -----------------------------
            % Syntax:       count = H.Count();
            %               
            % Outputs:      count is the number of key-value pairs in H
            %               
            % Description:  Returns the number of key-value pairs in H
            %--------------------------------------------------------------
            
            count = this.k;
        end
        
        %
        % Check for empty hash table
        %
        function bool = IsEmpty(this)
            %------------------------- IsEmpty ----------------------------
            % Syntax:       bool = H.IsEmpty();
            %               
            % Outputs:      bool = {true,false}
            %               
            % Description:  Determines if H is empty (i.e., contains zero
            %               key-value pairs)
            %--------------------------------------------------------------
            
            if (this.k == 0)
                bool = true;
            else
                bool = false;
            end
        end
        
        %
        % Clear the hash table
        %
        function Clear(this)
            %------------------------- Clear ------------------------------
            % Syntax:       H.Clear();
            %               
            % Description:  Removes all key-value pairs from H
            %--------------------------------------------------------------
            
            % Reset length
            this.k = 0;
            
            % Clear hash lists
            for jj = 1:this.m
                this.L(jj,1) = HashList();
            end
        end
    end
    
    %
    % Private methods
    %
    methods (Access = private)
        %
        % Initialize hash function
        % 
        % For HashCode() to be universal, the following criteria should be
        % met: 
        % 
        % - Criteria for this.p -
        %   1) this.p is prime
        %   2) this.p > this.m
        %   3) this.p > 75 = #{possible values (alphanumeric) for key(i)}
        %   3) this.p is large compared to ExpectedValue(length(key))
        %
        % - Criteria for randomized parameters -
        %   1) this.a is an integer in [1,...,this.p - 1]
        %   2) this.b is an integer in [0,...,this.p - 1]
        %   3) this.c is an integer in [1,...,this.p - 1]
        %
        function InitHashFunction(this)
            % Set prime parameter
            ff = 1000; % fudge factor
            pp = ff * max(this.m + 1,76);
            pp = pp + ~mod(pp,2); % make odd
            while (isprime(pp) == false)
                pp = pp + 2;
            end
            this.p = pp; % sufficiently large prime number
            
            % Randomized parameters
            this.a = randi([1,(pp - 1)]);
            this.b = randi([0,(pp - 1)]);
            this.c = randi([1,(pp - 1)]);
        end
        
        %
        % Compute the hash code of a given key
        %
        % - Assumptions for key -
        %   1) key(i) is alphanumeric char: {0,...,9,a,...,z,A,...,Z}
        %
        function hk = HashCode(this,key)
            % Convert character array to integer array
            ll = length(key);
            if (ischar(key) == false)
                % Non-character key
                HashTable.KeySyntaxError();
            end
            key = double(key) - 47; % key(i) = [1,...,75]
            
            %
            % Compute hash of integer vector
            %
            % Reference: http://en.wikipedia.org/wiki/Universal_hashing
            %            Sections: Hashing integers
            %                      Hashing strings
            %
            hk = key(1);
            for i = 2:ll
                % Could be implemented more efficiently in practice via bit
                % shifts (see reference)
                hk = mod(this.c * hk + key(i),this.p);
            end
            hk = mod(mod(this.a * hk + this.b,this.p),this.m) + 1;
        end
    end
    
    %
    % Private static methods
    %
    methods (Access = private, Static = true)
        %
        % Key not found error
        %
        function KeyNotFoundError(key)
            error('HashTable does not contain key ''%s''',key);
        end
        
        %
        % Key syntax error
        %
        function KeySyntaxError()
            error('HashTable keys must be nonempty alphanumeric strings');
        end
        
        %
        % Cell indexing error
        %
        function CellIndexingError()
            error('{} not supported for HashTable indexing. Use () instead');
        end
        
        %
        % Private property set error
        %
        % Note: This is similar to MATLAB's standard error message when
        % one tries to set a private set property of an object
        %
        function PrivatePropertySetError(field)
            error('Setting the ''%s'' property of the ''HashTable'' class is not allowed',field);
        end
    end
end
