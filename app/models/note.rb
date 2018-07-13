class Note < ApplicationRecord
 include Garden::Fruit

 def name
   [self.class.name, id, title].join(',')
 end  
end
