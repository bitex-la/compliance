class Note < ApplicationRecord
 include Garden::Fruit

 def name
   build_name("note")
 end  
end
