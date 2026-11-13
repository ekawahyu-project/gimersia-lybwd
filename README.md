# Gimersia *(Working Title)*

Game **2D Oblique Top-Down** bertema **kepedulian sosial dan gotong royong masyarakat pedesaan**, bergenre *Adventure*, *Exploration*, dan *Social Life-Simulation*, yang dibangun menggunakan **Godot Engine 4.7** (GDScript).

---

## Ringkasan Proyek

| Parameter | Detail |
| :--- | :--- |
| **Judul** | Gimersia *(Working Title)* |
| **Genre** | Adventure, Exploration, Social Life-Simulation |
| **Tema** | Kepedulian Sosial & Gotong Royong Masyarakat Pedesaan |
| **Perspektif & Visual** | 2D Oblique Top-Down |
| **Engine & Bahasa** | Godot Engine 4.7 (`Forward Plus`) & GDScript |
| **Platform Target** | PC (Windows / Desktop) |
| **Kondisi Menang (*Win State*)** | Mencapai **Badge Gold** (15 misi selesai) dan reputasi tertinggi (*Pahlawan Desa*), dengan mode *sandbox / free-roam* tetap terbuka setelahnya |

---

## Fitur Utama *(Rencana Desain)*

### 1. *Core Gameplay Loop*
1. **Eksplorasi:** Jelajahi area desa melalui gerbang gapura dan temukan NPC dengan indikator tanda seru (`!`).
2. **Interaksi:** Dekati NPC dan tekan ikon `(!)` atau tombol interaksi untuk membaca permasalahan lalu memilih **Terima** atau **Tolak**.
3. **Eksekusi Misi:** Selesaikan objektif (mencari petunjuk/barang berindikator kuning, mengawal NPC, atau mengusir gangguan) sebelum *timer* habis.
4. **Klaim Imbalan:** Laporkan kembali ke NPC pemberi misi untuk memperoleh **Koin**, **XP**, **Reputasi**, dan progres **Badge**.
5. **Progresi & Ekspansi:** Naikkan Level untuk membuka area baru dan belanjakan Koin di *Shop* untuk membeli *Pet* pendamping maupun item konsumsi.

### 2. Kontrol
- `W` / `A` / `S` / `D` — Bergerak 4/8 arah
- `Shift` (tahan) — *Sprint*
- `Klik Kiri` pada ikon `(!)` / `E` — Berinteraksi dengan NPC atau objek misi
- `Tab` — Membuka / menutup *Inventory*

### 3. Misi (*Repeatable Quests*)
1. **Lost Pet** *(Area Perumahan — Nenek)*: Mencari petunjuk dan menemukan kucing yang hilang.
2. **Safe Crossing** *(Area Perumahan — Nenek/Kakek)*: Mengawal NPC menyeberang dengan aman.
3. **Broken Bicycle** *(Area Perumahan — Anak Kecil)*: Mengumpulkan kunci pas serta pompa ban dan memperbaiki sepeda.
4. **Clean the Park** *(Area Taman — Petugas Kebersihan)*: Mengumpulkan sampah di taman dan membuangnya ke tong sampah.
5. **Save the Garden** *(Area Taman — Tukang Kebun)*: Mengusir kelinci pengganggu tanaman keluar dari area kebun.

### 4. Progresi, Ekonomi, & Reputasi
- **Level & Area Terbuka:**
  - **Lv 1 (100 XP):** Area Perumahan
  - **Lv 2 (+200 XP / Total 300 XP):** Area Air Terjun
  - **Lv 3 (+300 XP / Total 600 XP):** Area Pasar
  - **Lv 4 (+400 XP / Total 1.000 XP):** Area Taman
- **Badge:** Bronze (5 misi), Silver (10 misi), Gold (15 misi).
- **Reputasi:** *Pemula* (`0–20`), *Dikenal Warga* (`21–50`), *Dipercaya Warga* (`51–80`), *Pahlawan Desa* (`81–100`).
- **Sistem Pendukung:** *Inventory* (item konsumsi & alat/item khusus), *Shop* (item & *Pet* pendamping), *Settings* (slider BGM & SFX), serta penyimpanan otomatis lokal (`SaveManager`).

---

## Struktur Proyek

```text
gimersia/
├── assets/
│   ├── audio/          # Musik latar (BGM) dan efek suara (SFX)
│   └── sprites/        # Aset visual 2D (karakter, NPC, pet, tileset, props, ikon)
├── scenes/             # Scene Godot (.tscn)
├── scripts/            # Skrip GDScript (.gd)
├── ui/                 # Antarmuka pengguna (Main Menu, HUD, Dialog, Shop, Inventory)
├── GEMINI.md           # Aturan teknis pengembangan proyek
├── prd_gimersia.md     # Product Requirements Document (PRD)
├── project.godot       # Konfigurasi utama proyek Godot 4.7
└── README.md           # Dokumentasi repositori
```

> Folder kosong menggunakan file `.gdkeep` agar struktur direktori tetap terdeteksi pada sistem kontrol versi.

---

## Aturan Pengembangan

Mengacu pada [GEMINI.md](./GEMINI.md):
- Menggunakan **Godot 4.7** dengan bahasa pemrograman **GDScript** (tidak menggunakan C#).
- Menggunakan sintaks, tipe data, dan pemanggilan API sesuai standar Godot 4.x terbaru.
- Pada tahap awal prototipe, visual menggunakan node geometris bawaan (`ColorRect`, `Polygon2D`, dsb.) sebagai *placeholder* sebelum aset final dari tim *artist* tersedia.
- Setiap kali scene utama dibuat, *Main Scene* wajib diatur pada `project.godot`.

---

## Cara Membuka Proyek

1. Pastikan **Godot Engine 4.7** sudah terpasang.
2. Clone repositori ini:
   ```bash
   git clone <URL_REPOSITORI_GITHUB_ANDA>
   ```
3. Buka Godot Project Manager, klik **Import**, lalu pilih file `project.godot` di dalam folder proyek.
4. *(Catatan: proyek saat ini masih berada pada tahap awal sebelum implementasi Fase 1, sehingga `run/main_scene` di `project.godot` akan ditambahkan ketika scene utama pertama dibuat.)*

---

## Roadmap Pengembangan

- [ ] **Fase 1 — Pondasi & Gerak:** Setup *autoload* `GameManager`, peta *placeholder* Area Perumahan, gerak karakter `WASD + Shift`, `Camera2D`, dan HUD dasar.
- [ ] **Fase 2 — Sistem Dialog & Misi Pertama:** Interaksi ikon `!`, kotak dialog Terima/Tolak, *timer* misi, dan implementasi misi **Lost Pet** beserta imbalannya.
- [ ] **Fase 3 — Ekspansi 4 Misi & Progresi:** Implementasi *Safe Crossing*, *Broken Bicycle*, *Clean the Park*, *Save the Garden*, sistem Level/pembukaan area, dan kalkulasi Badge.
- [ ] **Fase 4 — Shop, Inventory, Save, & Polish:** *Main Menu* (latar *Gaussian Blur*), *Settings* audio, *Inventory*, *Shop* (sistem *Pet*), *Save/Load*, dan penggantian aset final dari tim *artist*.
