# Daily Planner App

**Nama:** Darren Christopher  
**NIM:** C14220119  
**Mata Kuliah:** UAS Flutter AMBW

## 📌 Deskripsi Aplikasi

**Daily Planner App** adalah aplikasi manajemen aktivitas harian yang memungkinkan pengguna untuk mencatat, mengelola, dan memantau tugas harian mereka berdasarkan tanggal dan kategori. Aplikasi ini didesain dengan UI yang sederhana dan navigasi yang intuitif menggunakan GoRouter.

---

## ✨ Fitur Utama

- **Authentication**
  - Sign Up, Sign In, dan Sign Out menggunakan **Supabase Auth**
  - Validasi input email dan password
  - Pesan kesalahan ditampilkan saat login gagal

- **Task Management (Daily Plan)**
  - Tambah task dengan:
    - Judul
    - Tanggal
    - Deskripsi
    - Kategori
  - Edit dan update task
  - Checklist jika task sudah selesai
  - Filter task berdasarkan waktu:
    - Hari ini
    - Besok
    - Minggu ini
    - Minggu depan

- **Session Persistence**
  - Informasi login disimpan menggunakan **SharedPreferences**
  - Pengguna tidak perlu login ulang saat membuka kembali aplikasi

- **Get Started Screen**
  - Ditampilkan hanya saat aplikasi pertama kali di-install
  - Selanjutnya akan diarahkan ke login atau home

- **Desain UI & Navigasi**
  - Navigasi antar halaman menggunakan **GoRouter**
  - UI sederhana, responsive, dan mudah digunakan

---

## 🚀 Cara Instalasi & Build

1. User Login
    ```bash
    email : c14220119@john.petra.ac.id
    pass : 123456

2. Clone repository:
   ```bash
   git clone https://github.com/darrenchrist30/UAS-Flutter-Darren-C14220119