class Note < ApplicationRecord
 include Garden::Fruit

 def name
   [id, title].join(',')
 end  
end
