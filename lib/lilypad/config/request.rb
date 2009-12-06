class Lilypad
  class Config
    class Request
      class <<self
        
        def action(action=nil)
          @action = action unless action.nil?
          @action
        end
        
        def component(component=nil)
          @component = component unless component.nil?
          @component
        end
        
        def reset!
          self.instance_variables.each do |name|
            eval "#{name} = nil"
          end
        end
      end
    end
  end
end