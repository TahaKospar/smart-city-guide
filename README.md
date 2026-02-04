# 🏙️ Smart City Guide

**Smart City Guide** is a comprehensive Flutter application designed to help tourists and locals explore the best attractions and restaurants in Egypt's major cities (Cairo, Giza, Luxor, Aswan). It features a responsive design, persistent favorite lists, and a seamless user experience.

---

## 📱 App Screenshots

Here is a glimpse of the application's interface:

| Welcome & Login | Home Feed | Details View | Favorites |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/image1.jpeg" width="180"/> | <img src="screenshots/image2.jpeg" width="180"/> | <img src="screenshots/image3.jpeg" width="180"/> | <img src="screenshots/image4.png" width="180"/> |

| Alerts & Dialogs | Places View | Location/Map |
|:---:|:---:|:---:|
| <img src="screenshots/image5.jpeg" width="180"/> | <img src="screenshots/image6.jpeg" width="180"/> | <img src="screenshots/image7.jpeg" width="180"/> |

> *Note: The app is fully responsive and adapts to Tablet/Web layouts.*

---

## ✨ Key Features

* **🗺️ Explore:** Browse a curated list of top tourist attractions and restaurants (Pyramids, Cairo Tower, etc.).
* **🔍 Search:** Quickly find specific places by name using the custom search delegate.
* **❤️ Favorites System:** Save your favorite places locally using `shared_preferences`. Data persists even after closing the app.
* **📱 Responsive Design:** Grid layout automatically adjusts columns based on screen width (Mobile vs Tablet).
* **📂 Drawer Navigation:** Access user profile and settings easily.
* **📍 Location Integration:** Ready for geolocation services.

---

## 🛠️ Tech Stack & Libraries

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** `setState` (Simple & Efficient)
* **Local Storage:** [`shared_preferences`](https://pub.dev/packages/shared_preferences)
* **Geolocation:** [`geolocator`](https://pub.dev/packages/geolocator)
* **UI Components:** `TabBar`, `GridView`, `Card`, `AwesomeDialog`.

---

## 🚀 How to Run

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YourUsername/flutter_application_1.git](https://github.com/YourUsername/flutter_application_1.git)
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```text
lib/
├── assets/          # Images and icons
├── details.dart     # Place details screen logic
├── favPage.dart     # Favorites screen logic
├── homePage.dart    # Login & Authentication UI
├── main.dart        # Entry point
└── Page1.dart       # Main Dashboard (Tabs & Grid)

## 👨‍💻 Author

**Taha**
* **University:** Delta Technological University (DTU)
* **Faculty:** Faculty of Industry and Energy Technology
* **Department:** Information Technology (IT)
* **Specialization:** Software & Flutter Development.
