# Digital Certificate Directory

A Flutter application for managing and storing digital certificates with a comprehensive repository system.

## Features

### 🔐 Authentication
- Login system with email validation
- Simulated authentication (ready for real backend integration)

### 📁 Certificate Repository
- **Add Certificates**: Upload PDF, images, and documents
- **Search & Filter**: Find certificates by name, description, or category
- **View Details**: See comprehensive certificate information
- **Delete Certificates**: Remove certificates with confirmation
- **File Management**: Automatic file storage and organization

### 🗄️ Database Integration
- **SQLite Database**: Local storage for certificate metadata
- **File Storage**: Secure local file storage for certificate files
- **Categories**: Organize certificates by type (Academic, Medical, Training, etc.)
- **Search**: Full-text search across certificate data

### 📱 User Interface
- **Modern Design**: Material Design 3 with beautiful gradients
- **Responsive**: Works on all screen sizes
- **Intuitive Navigation**: Bottom navigation with 3 main sections
- **Pull to Refresh**: Update certificate lists easily

## Database Schema

The app uses SQLite with the following structure:

```sql
CREATE TABLE certificates(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  fileName TEXT NOT NULL,
  filePath TEXT NOT NULL,
  fileType TEXT NOT NULL,
  fileSize REAL NOT NULL,
  uploadDate TEXT NOT NULL,
  description TEXT,
  category TEXT
);
```

## Supported File Types

- **PDF** (.pdf)
- **Images** (.jpg, .jpeg, .png)
- **Documents** (.doc, .docx)

## Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```

3. **Login**: Use any valid email format and password (6+ characters)

4. **Add Certificates**: 
   - Tap the "+" button on the home screen
   - Fill in certificate details
   - Upload a file
   - Save to repository

## Project Structure

```
lib/
├── models/
│   └── certificate.dart          # Certificate data model
├── services/
│   ├── database_helper.dart      # SQLite database operations
│   └── certificate_service.dart  # File and database management
├── screens/
│   ├── login_page.dart           # Authentication screen
│   ├── home_page.dart            # Main certificate list
│   ├── repository_page.dart      # Certificate repository
│   ├── certificate_form_page.dart # Add new certificates
│   └── profile_page.dart         # User profile
└── widgets/
    └── custom_navigation_bar.dart # Bottom navigation
```

## Dependencies

- `sqflite`: SQLite database
- `path_provider`: File system access
- `file_picker`: File selection
- `intl`: Date formatting
- `uuid`: Unique ID generation

## Future Enhancements

- [ ] Real authentication backend
- [ ] Cloud storage integration
- [ ] Certificate validation
- [ ] Export/backup functionality
- [ ] Certificate sharing
- [ ] Advanced search filters
- [ ] Certificate templates

## License

This project is for educational and personal use.
