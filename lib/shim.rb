class Shim
	def initialize(clazz, deprecate, method_map)
		if class_method_map = method_map.delete(:self)
			meta_class = class << clazz; self end
			redefine_methods(meta_class, deprecate, class_method_map)
		end
		redefine_methods(clazz, deprecate, method_map)
	end

	def redefine_methods(clazz, deprecate, method_map)
		method_map.each do |unknown_method, existing_method|
			redefine_method(clazz, deprecate, unknown_method, existing_method)
		end
	end

	def redefine_method(clazz, deprecate, unknown_method, existing_method)
		if deprecate
			clazz.__send__(:define_method, unknown_method) do |*args|
				ActiveSupport::Deprecation.warn("Calling #{self.name}##{unknown_method} is deprecated, please use ##{existing_method}", caller)
				__send__(existing_method,*args)
			end
		else
			clazz.send(:define_method, unknown_method) do |*args|
				__send__(existing_method,*args)
			end
		end
	end
end
