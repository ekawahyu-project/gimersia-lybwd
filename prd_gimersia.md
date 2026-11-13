# Product Requirements Document (PRD): Gimersia

## 1. Ikhtisar Produk (*Product Overview*)

| Parameter | Detail |
| :--- | :--- |
| **Judul Proyek** | Gimersia *(Working Title)* |
| **Genre** | Adventure, Exploration, Social Life-Simulation |
| **Tema** | Kepedulian Sosial & Gotong Royong Masyarakat Pedesaan |
| **Perspektif & Visual** | 2D Oblique Top-Down (sudut pandang atas agak miring) |
| **Target Engine** | Godot Engine 4.7 (GDScript) |
| **Platform Target** | PC (Windows/Desktop) |
| **Kondisi Menang (*Win State*)** | Menyelesaikan 5 jenis misi secara berulang hingga mencapai Badge Gold (15 misi) dan tingkat reputasi tertinggi (*Pahlawan Desa*), dengan mode *sandbox/free-roam* yang tetap terbuka setelahnya. |

---

## 2. Alur Permainan (*Core & Engine Loop*)

### A. *Core Gameplay Loop*
1. **Eksplorasi:** Pemain berjalan menyusuri area desa melalui pintu masuk gapura dan mencari NPC dengan ikon tanda seru (`!`) di atas kepala.
2. **Interaksi:** Pemain mendekati NPC, menekan ikon (`!`) atau tombol interaksi, membaca dialog permasalahan, dan memilih **Terima** atau **Tolak**.
3. **Eksekusi Misi:** Pemain menyelesaikan objektif (mencari petunjuk/barang berindikator kuning, mengawal NPC, atau mengusir gangguan) sebelum *timer* habis.
4. **Klaim Imbalan:** Pemain kembali melapor ke NPC pemberi misi untuk mendapatkan Koin, XP, Reputasi, dan progres Badge.
5. **Progresi & Ekspansi:** XP menaikkan Level untuk membuka area baru; Koin dibelanjakan di *Shop* (Pet & item konsumsi); Reputasi membuka dialog serta misi spesial.

### B. Arsitektur *Engine Loop* (Godot 4.7)
* **Input Processing (`_unhandled_input` / `Input`):** Membaca `W, A, S, D` (gerak), `Shift` (lari), `Tab` (buka/tutup Inventory), dan klik mouse (interaksi ikon `!` serta navigasi UI).
* **Fixed Logic Update (`_physics_process`):** Menghitung kecepatan/kolisi karakter, mendeteksi jarak interaksi (`Area2D`), menghitung mundur *timer* misi, memvalidasi kondisi selesai/gagal, dan memperbarui state data pemain.
* **Rendering & Interpolation (`_process`):** Memperbarui animasi karakter/NPC, indikator kuning objek misi, ikon `!`, angka HUD, dan efek visual perubahan lingkungan setelah misi tuntas.

---

## 3. Spesifikasi Sistem & Mekanik Utama

### A. Kontrol & Kamera
* **Kamera:** `Camera2D` menempel pada pemain dengan *smoothing* aktif untuk mengikuti pergerakan eksplorasi di atas peta 2D Oblique Top-Down.
* **Skema Kontrol:**
  * `W / A / S / D` : Bergerak 4/8 arah.
  * `Shift` (tahan) : *Sprint* (meningkatkan kecepatan gerak).
  * `Klik Kiri pada Ikon (!)` / `E` : Berinteraksi dengan NPC atau mengambil/menggunakan objek misi (saat berada dalam radius interaksi).
  * `Tab` : Membuka/menutup jendela *Inventory*.

### B. Sistem Progresi, Ekonomi, & Reputasi

| Sistem | Aturan & Ambang Batas (*Thresholds*) | Fungsi dalam Game |
| :--- | :--- | :--- |
| **Koin** | Diperoleh dari penyelesaian misi (+50 s.d. +70 koin). | Mata uang untuk membeli **Pet** (pendamping yang mengikuti karakter) dan **Makanan/Minuman** di *Shop*. |
| **XP & Level** | • Level 1: 100 XP<br>• Level 2: +200 XP (Total 300 XP)<br>• Level 3: +300 XP (Total 600 XP)<br>• Level 4: +400 XP (Total 1.000 XP) | Membuka akses gerbang area baru secara bertahap:<br>• **Lv 1:** Area Perumahan<br>• **Lv 2:** Area Air Terjun<br>• **Lv 3:** Area Pasar<br>• **Lv 4:** Area Taman |
| **Badge** | • **Bronze:** 5 misi selesai<br>• **Silver:** 10 misi selesai<br>• **Gold:** 15 misi selesai | Lencana pencapaian yang ditampilkan langsung pada sudut kanan atas HUD. |
| **Reputasi** | • **Berhasil Misi:** `+5` poin<br>• **Batal Misi Sengaja:** `-5` poin<br>• **Waktu Habis (Gagal):** `-3` poin<br><br>**Tingkatan:**<br>• `0–20`: Pemula<br>• `21–50`: Dikenal Warga<br>• `51–80`: Dipercaya Warga<br>• `81–100`: Pahlawan Desa | Menentukan kepercayaan warga. Reputasi tinggi membuka dialog & misi khusus; reputasi rendah membatasi akses misi dari NPC tertentu. |

### C. Desain Misi (*Repeatable Quest System*)
Semua misi bersifat **dapat diulang (*repeatable*)** dari NPC yang berbeda-beda dan memiliki **batas waktu (*countdown timer*)** (standar 30 detik, dapat disesuaikan per tingkat kesulitan misi).

1. **Lost Pet (Area Perumahan)**
   * **NPC:** Nenek | **Reward:** 50 Koin, 20 XP, +5 Reputasi.
   * **Alur:** Terima misi → Cari & periksa petunjuk berindikator kuning di sekitar perumahan → Temukan kucing berdasarkan arah petunjuk → Interaksi dengan kucing → Kembali ke Nenek.
2. **Safe Crossing (Area Perumahan)**
   * **NPC:** Nenek/Kakek | **Reward:** 55 Koin, 25 XP, +5 Reputasi.
   * **Alur:** Terima misi → Interaksi ulang untuk mulai mengawal → Jalan menuju titik tujuan penyeberangan sambil menjaga jarak agar NPC tetap mengikuti hingga titik aman tercapai.
3. **Broken Bicycle (Area Perumahan)**
   * **NPC:** Anak kecil | **Reward:** 60 Koin, 30 XP, +5 Reputasi.
   * **Alur:** Terima misi → Kumpulkan alat berindikator kuning (kunci pas, pompa ban) → Kembali ke sepeda rusak dan interaksi untuk memperbaiki.
4. **Clean the Park (Area Taman)**
   * **NPC:** Petugas Kebersihan | **Reward:** 70 Koin, 30 XP, +5 Reputasi.
   * **Alur:** Terima misi → Kumpulkan seluruh sampah berindikator kuning di taman → Interaksi dengan tong sampah untuk membuangnya.
5. **Save the Garden (Area Taman)**
   * **NPC:** Tukang Kebun | **Reward:** 55 Koin, 25 XP, +5 Reputasi, Item Khusus (*Bibit Bunga*).
   * **Alur:** Terima misi → Dekati dan interaksi dengan setiap kelinci pengganggu tanaman untuk mengusirnya keluar area → Kembali ke Tukang Kebun.

### D. Inventory, Shop, & Save System
* **Inventory (`Tab`):** Menampilkan grid/daftar item milik pemain yang terbagi menjadi kategori *Konsumsi* (makanan/minuman) dan *Alat-Alat / Item Khusus* (seperti bibit bunga).
* **Shop:** Antarmuka transaksi menggunakan koin untuk membeli item konsumsi serta membuka/memilih *Pet* pendamping.
* **Save System (`SaveManager`):** Menyimpan data JSON/Resource lokal secara otomatis saat misi selesai atau transaksi terjadi (mencakup Koin, XP, Level, Reputasi, Badge, Isi Inventory, Pet aktif, dan riwayat misi).

---

## 4. Kebutuhan Antarmuka (*UI / UX*) & Audio

* **Main Menu:** Latar ilustrasi lingkungan desa dengan efek *Gaussian Blur*, Logo Judul Game, tombol **START**, tombol **SETTINGS**, dan tombol **CONTINUE** (jika file simpanan tersedia).
* **In-Game HUD:**
  * *Kiri Atas:* Bar Level & XP, Jumlah Koin, Status Reputasi (angka & gelar).
  * *Kanan Atas:* Ikon Badge aktif (Bronze/Silver/Gold) & tombol cepat Inventory/Settings.
  * *Tengah Atas (kondisional):* Panel misi aktif beserta *timer* hitung mundur saat misi berjalan.
  * *Bawah:* Kotak dialog NPC (potret/nama NPC, teks dialog, tombol Terima/Tolak).
* **Settings Menu:** Slider terpisah untuk **BGM (Background Music)** dan **SFX (Sound Effects)** yang dapat diakses dari Main Menu maupun saat permainan berlangsung (*Pause*).
* **Daftar Kebutuhan Audio:** Musik latar pedesaan yang tenang, SFX langkah kaki, interaksi dialog, ambil item, *timer* kritis, misi berhasil, dan *level up / reward*.

---

## 5. Kebutuhan Aset untuk Tim *Artist* (*Asset Checklist*)

1. **Karakter & Pendamping:** *Sprite sheet* Pemain (Idle & Walk 4 arah), variasi NPC (Nenek, Kakek, Anak, Petugas Kebersihan, Tukang Kebun), dan *Pet* (kucing/anjing pendamping).
2. **Lingkungan (*Tileset* & Props 2D Oblique):** Tanah/rumput, jalan beraspal/setapak, gapura desa, rumah warga, bangku taman, pohon, tong sampah, tanaman bunga, serta kendaraan lalu lintas untuk misi menyeberang.
3. **Objek Misi & Ikon UI:** Ikon tanda seru (`!`), efek *highlight* indikator kuning, sampah berserakan, kunci pas, pompa ban, sepeda rusak & diperbaiki, kelinci, serta ikon Badge (Bronze, Silver, Gold).

---

## 6. Roadmap Pengerjaan *Vibecoding* (Bertahap)

* **Fase 1 (Pondasi & Gerak):** Setup *autoload* `GameManager`, peta *placeholder* Area Perumahan, gerak karakter `WASD + Shift`, kamera, dan HUD dasar.
* **Fase 2 (Sistem Dialog & 1 Misi Pertama):** Sistem interaksi ikon `!`, kotak dialog Terima/Tolak, *timer* misi, dan implementasi penuh misi **Lost Pet** beserta pemberian Reward.
* **Fase 3 (Ekspansi 4 Misi & Progresi):** Menambahkan misi *Safe Crossing*, *Broken Bicycle*, *Clean the Park*, *Save the Garden*, sistem Level/pembukaan area, dan kalkulasi Badge.
* **Fase 4 (Shop, Inventory, Save, & Polish):** Menu *Main Menu* (latar blur), *Settings* audio, *Inventory*, *Shop* (sistem *Pet* mengikuti pemain), *Save/Load*, dan penggantian aset asli dari *artist*.