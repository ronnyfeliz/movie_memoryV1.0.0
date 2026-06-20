# 🍿 MovieMemory

<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
<img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
<img src="https://img.shields.io/badge/TMDB--API-V3-01b4e4?style=for-the-badge&logo=themoviedatabase&logoColor=white" alt="TMDB API" />
<img src="https://img.shields.io/badge/License-Educational-4CAF50?style=for-the-badge" alt="License" />

**An Intelligent Multimedia Platform for Movies and TV Series**

*Discover, organize, and enjoy your favorite content in one place.*

[🌐 Website Link](https://medfamily-app.netlify.app/) | [🇹🇭 Leer en Español](#🇹🇭-versión-en-español)

</div>

---

## ℹ️ Overview

**MovieMemory** is a feature-rich, high-performance multimedia ecosystem built with **Flutter** and **Firebase**. Designed with visual excellence and user experience in mind, it allows movie enthusiasts to seamlessly discover trending content, organize custom collections, track watch history, and stream media through an optimized interface.

Originally conceived as a personal media library, the project evolved into a complete multimedia ecosystem featuring personalized lists, public collections, content discovery tools, multilingual support, and integrated streaming capabilities.

---

## ✨ Features

### 🔍 Content Discovery
* **Trending Feeds:** Browse popular movies, trending shows, and top-rated titles.
* **Advanced Search:** Find titles using powerful filters for genres, release years, and cast details.
* **Rich Metadata:** Detailed pages showing casts, production companies, official trailers, and media assets.

### 📁 Personal Library & Custom Lists
* **Status Tracking:** Mark titles as favorites, track watch history, and manage viewing status.
* **Custom Playlists:** Create unlimited custom lists (public or private).
* **Community Sharing:** Follow public lists created by the community and share your collections.

### 🌐 Multilingual Support
* **Fully Bilingual:** Native English and Spanish support.
* **Locale Cache:** Language-aware content caching and dynamic language switching without reloading.

### 🎥 Multimedia Playback
* **Integrated Streaming:** Built-in high-performance video player (BetterPlayer) and WebView fallbacks.
* **Intelligent Routing:** Smart server selection, streaming optimization, and subtitle rendering.

### ☁️ Cloud Sync & Integration
* **User Authentication:** Secure email/password login powered by Firebase Auth.
* **Real-time Sync:** Cloud Firestore syncs user preferences, favorites, and custom lists instantly across all devices.

---

## 📱 Interface Tour

<table align="center">
  <tr>
    <td align="center" width="30%">
      <img src="https://github.com/user-attachments/assets/d30bda2c-9209-437a-b9d9-879ec73d5333" width="100%" />
      <br><sub><b>Splash & Login</b></sub>
    </td>
    <td align="center" width="30%">
      <img src="https://github.com/user-attachments/assets/e2089a85-a53a-49e1-a8a0-660009777ba3" width="100%" />
      <br><sub><b>Home Dashboard</b></sub>
    </td>
    <td align="center" width="30%">
      <img src="https://github.com/user-attachments/assets/d6944f48-c8d2-47ae-b3e5-383c7686e455" width="100%" />
      <br><sub><b>Content Discovery</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/ef76de87-f954-46c7-9cc5-b4df5b5ab446" width="100%" />
      <br><sub><b>Media Details</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/1640b539-63f8-4bcf-b051-bb4cab38f8ac" width="100%" />
      <br><sub><b>Cast & Information</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/00f104eb-ee65-40f3-abef-faac5666d292" width="100%" />
      <br><sub><b>Custom Lists</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/05777db9-26c9-4bb6-834f-faf90e9ba6ab" width="100%" />
      <br><sub><b>Favorites</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/8d6aef7b-5d9d-430d-bb6e-5b9c67212577" width="100%" />
      <br><sub><b>Watch History</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/b9aaaf9f-95b9-44ed-a15f-db31c44c2997" width="100%" />
      <br><sub><b>Profile & Settings</b></sub>
    </td>
  </tr>
</table>

<br>

<p align="center">
  <b>🎥 Landscape Player Experience</b><br><br>
  <img src="https://github.com/user-attachments/assets/89fc463b-4107-495f-bb00-a8dfc299ec5b" width="80%" alt="Landscape Streaming Player" />
</p>

---

## 🛠️ Architecture & Folder Structure

MovieMemory adheres to standard clean development architectures for Flutter, modularizing layers to ensure high testability, maintainability, and scalability.

```text
lib/
├── core/                  # Global configurations, themes, and global constants
│   ├── theme/             # App typography, custom color palette
│   ├── utils/             # Helper classes and shared functions
│   └── localization/      # Translations & multi-language engine (EN/ES)
├── data/                  # Data access layer
│   ├── models/            # TMDB Media models, Users, and Lists definitions
│   ├── providers/         # Firebase handlers & raw HTTP request handlers
│   └── repositories/      # Repository patterns mapping local/remote sources
└── presentation/          # User Interface (UI) Components
    ├── screens/           # Main application view screens
    │   ├── auth/          # Registration, login, and forgot password flow
    │   ├── home/          # Main feed containing banners and lists
    │   ├── discover/      # Browse screens and active search bar
    │   ├── details/       # Cast profiles, details, and video player launch
    │   ├── lists/         # Custom, public, and followed playlists
    │   ├── streaming/     # BetterPlayer video stream player
    │   └── profile/       # User profile and settings
    └── widgets/           # Global reusable widgets (custom widgets)
```

---

## ⚙️ Configuration & Setup

### Prerequisites
* Flutter SDK (3.x or higher)
* Dart SDK
* An Android/iOS development environment (VS Code or Android Studio)
* A registered [Firebase Project](https://console.firebase.google.com/)
* A TMDB Account to request an API key

### 🚀 Installation
1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ronnyfeliz/moviememory.git
   cd moviememory
   ```
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

### 🔑 Configuration
#### Firebase Setup
1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Email/Password), **Cloud Firestore**, and **Firebase Storage**.
3. Create Android and iOS applications in the console.
4. Download and locate:
   * **Android:** `google-services.json` in `android/app/`
   * **iOS:** `GoogleService-Info.plist` in `ios/Runner/`

#### TMDB API Key Setup
1. Register on [The Movie Database (TMDB)](https://www.themoviedatabase.org/).
2. Head to settings and request an API key.
3. In the root directory, create a `.env` file and append:
   ```env
   TMDB_API_KEY=YOUR_TMDB_API_KEY
   ```

---

## 🚀 Future Roadmap

- [ ] **Social Enhancements**
  - [ ] Implement a social follow system for friends.
  - [ ] Add community reviews, ratings, and shared discussions.
- [ ] **AI-Powered Recommendation Engine**
  - [ ] Generate smart recommendations based on view patterns.
- [ ] **Expanded Catalogs**
  - [ ] Support for Anime, Cartoon, and Documentary filters.
- [ ] **Offline Mode**
  - [ ] Enable local SQLite/Hive offline sync caching.

---

## 👥 Meet the Developer

<table width="100%">
  <tr>
    <td width="20%" align="center">
      <img src="https://github.com/ronnyfeliz.png" width="100px" style="border-radius: 50%;" alt="Ronny Feliz" />
    </td>
    <td width="80%">
      <h3>Ronny Feliz</h3>
      <p><i>Technology enthusiast focused on software development, multimedia systems, and digital innovation.</i></p>
      <p>
        <a href="https://www.linkedin.com/in/ronnyfeliz2/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=flat-for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>
        <a href="https://github.com/ronnyfeliz"><img src="https://img.shields.io/badge/GitHub-100000?style=flat-for-the-badge&logo=github&logoColor=white" alt="GitHub" /></a>
        <a href="https://ronnyfeliz.github.io/"><img src="https://img.shields.io/badge/Portfolio-FF5722?style=flat-for-the-badge&logo=google-chrome&logoColor=white" alt="Portfolio" /></a>
      </p>
    </td>
  </tr>
</table>

---

## 📄 License

This project is licensed under the terms of the Educational/Portfolio License. Feel free to clone and explore for learning purposes.

---

## 🇹🇭 Versión en Español

<details>
<summary><b>Haz clic aquí para ver este archivo en Español</b></summary>

# 🍿 MovieMemory

<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
<img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
<img src="https://img.shields.io/badge/TMDB--API-V3-01b4e4?style=for-the-badge&logo=themoviedatabase&logoColor=white" alt="TMDB API" />
<img src="https://img.shields.io/badge/Licencia-Educativa-4CAF50?style=for-the-badge" alt="Licencia" />

**Una Plataforma Multimedia Inteligente para Películas y Series de TV**

*Descubre, organiza y disfruta de tu contenido favorito en un solo lugar.*

[🌐 Enlace al Sitio Web](https://medfamily-app.netlify.app/)

</div>

---

## ℹ️ Descripción General

**MovieMemory** es un ecosistema multimedia de alto rendimiento y repleto de funciones desarrollado con **Flutter** y **Firebase**. Diseñado con excelencia visual y excelente experiencia de usuario, permite a los entusiastas del cine descubrir contenido en tendencia, organizar colecciones personalizadas, rastrear su historial de reproducción y transmitir contenido a través de una interfaz optimizada.

Originalmente concebido como una biblioteca de medios personal, el proyecto evolucionó a un ecosistema multimedia completo que ofrece listas personalizadas, colecciones públicas, herramientas de descubrimiento de contenido, soporte multilenguaje y capacidades de reproducción integrada.

---

## 🉲✨ Características

### 🔍 Descubrimiento de Contenido
* **Feeds en Tendencia:** Explora películas populares, series en tendencia y los títulos mejor valorados.
* **Búsqueda Avanzada:** Encuentra títulos mediante potentes filtros por género, año de lanzamiento y detalles del reparto.
* **Metadatos Detallados:** Páginas completas con información de reparto, empresas productoras, avances oficiales y recursos multimedia.

### 📁 Biblioteca Personal y Listas Personalizadas
* **Seguimiento de Estado:** Marca títulos como favoritos, haz seguimiento al historial de reproducción y gestiona el estado de visualización.
* **Listas Personalizadas:** Crea listas personalizadas ilimitadas (públicas o privadas).
* **Comunidad:** Sigue listas públicas creadas por otros usuarios y comparte tus colecciones.

### 🌐 Soporte Multilenguaje
* **Totalmente Bilingüe:** Soporte nativo para inglés y español.
* **Caché Local Inteligente:** Carga de contenido según el idioma seleccionado y cambio dinámico sin recargar la aplicación.

### 🎥 Reproducción Multimedia
* **Streaming Integrado:** Reproductor de video de alto rendimiento integrado (BetterPlayer) y alternativas basadas en WebView.
* **Ruteo Inteligente:** Selección inteligente de servidores de streaming, optimización de velocidad y renderizado de subtítulos.

### ☁️ Sincronización e Integración en la Nube
* **Autenticación de Usuarios:** Acceso seguro mediante correo electrónico y contraseña gracias a Firebase Auth.
* **Sincronización en Tiempo Real:** Cloud Firestore sincroniza tus favoritos, listas y preferencias de forma instantánea en todos tus dispositivos.

---

## 🛠️ Arquitectura y Estructura del Proyecto

MovieMemory sigue los estándares de arquitectura limpia en Flutter, separando el proyecto por capas para asegurar alta testabilidad, mantenibilidad y escalabilidad.

```text
lib/
├── core/                  # Configuraciones globales, temas y constantes compartidas
│   ├── theme/             # Tipografía de la aplicación, paleta de colores personalizada
│   ├── utils/             # Clases de ayuda y funciones generales
│   └── localization/      # Motor de traducción e idiomas (EN/ES)
├── data/                  # Capa de acceso a datos
│   ├── models/            # Modelos de datos para TMDB, usuarios y listas
│   ├── providers/         # Manejadores de Firebase y peticiones HTTP crudas
│   └── repositories/      # Repositorios que mapean datos locales y remotos
└── presentation/          # Capa de Interfaz de Usuario (UI)
    ├── screens/           # Pantallas principales de la aplicación
    │   ├── auth/          # Registro, inicio de sesión y flujo de recuperación
    │   ├── home/          # Feed principal con banners y listas
    │   ├── discover/      # Pantallas de exploración y barra de búsqueda
    │   ├── details/       # Perfil del reparto, detalles y reproductor de video
    │   ├── lists/         # Listas de reproducción personalizadas y públicas
    │   ├── streaming/     # Reproductor de video (BetterPlayer)
    │   └── profile/       # Perfil de usuario y configuraciones
    └── widgets/           # Widgets reutilizables (botones, tarjetas y celdas personalizadas)
```

---

## ⚙️ Configuración e Instalación

### Prerrequisitos
* Flutter SDK (3.x o superior)
* Dart SDK
* Entorno de desarrollo para Android/iOS (VS Code o Android Studio)
* Un proyecto de [Firebase](https://console.firebase.google.com/) registrado
* Una cuenta en TMDB para solicitar una clave de API

### 🚀 Instalación
1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/ronnyfeliz/moviememory.git
   cd moviememory
   ```
2. **Instalar Dependencias:**
   ```bash
   flutter pub get
   ```

### 🔑 Configuración
#### Configuración de Firebase
1. Crea un proyecto en la [Consola de Firebase](https://console.firebase.google.com/).
2. Activa **Authentication** (Correo/Contraseña), **Cloud Firestore** y **Firebase Storage**.
3. Registra las aplicaciones Android e iOS en la consola.
4. Descarga y ubica:
   * **Android:** `google-services.json` en `android/app/`
   * **iOS:** `GoogleService-Info.plist` in `ios/Runner/`

#### Configuración de API de TMDB
1. Regístrate en [The Movie Database (TMDB)](https://www.themoviedatabase.org/).
2. Ve a la configuración de tu cuenta y solicita una clave de API.
3. En el directorio raíz, crea un archivo `.env` y agrega:
   ```env
   TMDB_API_KEY=TU_API_KEY_AQUI
   ```

---

## 🚀 Ruta de Desarrollo Futuro

- [ ] **Mejoras Sociales**
  - [ ] Implementar un sistema de seguimiento de amigos.
  - [ ] Agregar opiniones de la comunidad, calificaciones y debates compartidos.
- [ ] **Motor de Recomendaciones Inteligentes con IA**
  - [ ] Generar sugerencias inteligentes basadas en patrones de visualización.
- [ ] **Expansión de Catálogos**
  - [ ] Filtros para Anime, Caricaturas y Documentales.
- [ ] **Modo Sin Conexión (Offline)**
  - [ ] Habilitar sincronización local con SQLite/Hive.

---

## 👥 Sobre el Desarrollador

**Ronny Feliz** - Entusiasta de la tecnología enfocado en desarrollo de software, sistemas multimedia e innovación digital.

*   [LinkedIn](https://www.linkedin.com/in/ronnyfeliz2/)
*   [GitHub](https://github.com/ronnyfeliz)
*   [Portafolio](https://ronnyfeliz.github.io/)

</details>
