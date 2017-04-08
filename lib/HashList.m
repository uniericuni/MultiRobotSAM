classdef HashList < handle
%
% Class that implements a list (doubly linked with a sentinel) of elements
% of type HashListElement
%
% NOTE: This class is used internally by the HashTable class
%

    %
    % Private properties
    %
    properties (Access = private)
        k;                          % current number of elements
        root;                       % pointer to list root    
        nil;                        % sentinel element
    end
    
    %
    % Public methods
    %
    methods (Access = public)
        %
        % Constructor
        %
        function this = HashList()
            % Start with an empty list
            this.Clear();
        end
        
        %
        % Prepend element to list
        %
        function Prepend(this,key,value)
            % Create element
            x = HashListElement(key,value);
            this.k = this.k + 1;
            
            % Prepend to list
            x.next = this.root.next;
            this.root.next.prev = x;
            x.prev = this.root;
            this.root.next = x;
        end
        
        %
        % Append element to list
        %
        function Append(this,key,value)
            % Create element
            x = HashListElement(key,value);
            this.k = this.k + 1;
            
            % Append to list
            x.prev = this.root.prev;
            this.root.prev.next = x;
            x.next = this.root;
            this.root.prev = x;
        end
        
        %
        % Set value of (first) element with given key
        %
        function Set(this,key,value)
            x = this.FindKey(key);
            if ~isnan(x)
                x.value = value;
            end
        end
        
        %
        % Get value of (first) element with given key
        %
        function value = Get(this,key)
            x = this.FindKey(key);
            if ~isnan(x)
                value = x.value;
            end 
        end
        
        %
        % Delete (first) element with given key
        %
        function varargout = Remove(this,key)
            x = this.FindKey(key);
            if isnan(x)
                success = false;
            else
                this.k = this.k - 1;
                x.prev.next = x.next;
                x.next.prev = x.prev;
                success = true;
            end
            if (nargout == 1)
                varargout{1} = success;
            end
        end
        
        %
        % Search for Ifirst) element with given key
        %
        function bool = ContainsKey(this,key)
            bool = ~isnan(this.FindKey(key));
        end
        
        %
        % Return (first) element in list with given key
        %
        function x = FindKey(this,key)
            x = this.root.next;
            while (~isnan(x) && ~x.KeyEquals(key))
                x = x.next;
            end
        end
        
        %
        % Return all keys in list
        %
        function keys = Keys(this)
            keys = cell(this.k,1);
            x = this.root.next;
            i = 1;
            while (i <= this.k)
                keys{i} = x.key;
                x = x.next;
                i = i + 1;
            end
        end
        
        %
        % Return all values in list
        % 
        function values = Values(this)
            values = cell(this.k,1);
            x = this.root.next;
            i = 1;
            while (i <= this.k)
                values{i} = x.value;
                x = x.next;
                i = i + 1;
            end
        end
        
        %
        % Return number of elements in list
        %
        function count = Count(this)
            count = this.k;
        end
        
        %
        % Check for empty list
        %
        function bool = IsEmpty(this)
            if (this.k == 0)
                bool = true;
            else
                bool = false;
            end
        end
        
        %
        % Clear the list
        %
        function Clear(this)
            this.k = 0;                         % reset length counter
            this.nil = HashListElement(nan,[]); % reset nil pointer
            this.root = this.nil;               % reset root pointer
            this.root.next = this.nil;
            this.root.prev = this.nil;
        end
    end
end
