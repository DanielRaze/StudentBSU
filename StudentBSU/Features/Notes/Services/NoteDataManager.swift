import CoreData
import Foundation

class NoteDataManager {
    static let shared = NoteDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotesDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Ошибка загрузки Core Data: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения контекста: \(error)")
            }
        }
    }
    
    func fetchNotes() -> [Note] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities.map { Note(entity: $0)}
        } catch {
            print("Ошибка загрузки данных: \(error)")
            return []
        }
    }
    
    func deleteNote(_ note: Note) {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        do{
            let results = try context.fetch(request)
            if let noteToDelete = results.first {
                context.delete(noteToDelete)
                saveContext()
            }
        } catch {
            print("Ошибка при удалении заметки: \(error)")
        }
    }
    
    func saveNote (_ note: Note) {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        do{
            let results = try context.fetch(request)
            
            let entityToUpdate = results.first ?? NoteEntity(context: context)
            
            entityToUpdate.id = note.id
            entityToUpdate.title = note.title
            entityToUpdate.text = note.text
            entityToUpdate.tag = note.tag
            entityToUpdate.date = note.date
            entityToUpdate.colorIndex = Int16(note.colorIndex)
                
            saveContext()
        } catch {
            print("Ошибка при удалении заметки: \(error)")
        }
    }
}
