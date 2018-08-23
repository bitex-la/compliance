class Note < ApplicationRecord
 include Garden::Fruit

 def self.name_body(i)
   i.title || i.body
 end  
end
