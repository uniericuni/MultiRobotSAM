classdef HashListElement < handle
%
% A class that implements pass by reference key-value pairs with
% char/numeric keys and arbitrarily-typed values for instances of the
% HashList class
%
% NOTE: This class is used internally by the HashTable class
%

    %
    % Public properties
    %
	properties (Access = public)
		key;            % key
        value;          % value
        prev = nan;     % previous element
        next = nan;     % next element
    end
    
    %
    % Public methods
    %
	methods (Access = public)
        %
        % Constructor
        %
		function this = HashListElement(key,value)
            % Initialize element
            this.key = key;
            this.value = value;
        end
        
        %
        % Element is nan if its key is nan
        %
        function bool = isnan(this)
            if ischar(this.key)
                % character key
                bool = false;
            else
                % assume numeric key
                bool = isnan(this.key);
            end
        end
        
        %
        % Key equals
        %
        function bool = KeyEquals(this,key)
            if ischar(this.key)
                % character key
                bool = strcmp(this.key,key);
            else
                % assume numeric key
                bool = (this.key == key);
            end
        end
    end
end
