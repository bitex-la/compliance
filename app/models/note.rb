class Note < NoteBase
 include Garden::Fruit

 def self.name_body(i)
   i.title || i.body
 end  
end
