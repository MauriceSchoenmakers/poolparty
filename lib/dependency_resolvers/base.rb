=begin rdoc
  Base dependency_resolver
=end
module PoolParty
  module DependencyResolvers
    
    class Base
      
      def self.compile_to(resources=[], outdir=Dir.pwd)
        @compile_directory ||= outdir
        compile(resources)
      end
      
      def self.compile(resources=[])
        before_compile
        o = case resources
        when Array
          compile_array(resources)
        when PoolParty::Resource
          compile_resource(resources)
        end
        after_compile
        o
      end
      
      # CALLBACKS
      # Called before anything is compiled
      def self.before_compile
      end
      # Called after everything is compiled
      def self.after_compile
      end
      
      # The name of the method that the resource
      # should respond to to compile
      # Format:
      #   print_to_<dependency_resolver.name>
      def self.compile_method_name
        @compile_method_name ||= "print_to_#{name.to_s.top_level_class}".to_sym
      end
      
      private
      
      # Compile a resource directly
      def self.compile_resource(res)
        return nil unless res.respond_to?(compile_method_name)
        po = ProxyObject.new(res)
        po.compile(compile_method_name)
      end
      
      # Compile an array of resources
      def self.compile_array(array_of_resources=[])
        out = []
        array_of_resources.each do |res|                    
          out << compile_resource(res)
        end
        out.join("\n")
      end
      
      def self.compile_directory
        @compile_directory
      end
      
    end
    
  end
end