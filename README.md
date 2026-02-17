# Fraction Fixer for SketchUp LayOut

**Version 2.6.0** — by Mario Chabot

A SketchUp extension that converts text fractions (like `1/2`, `3/4`, `7/8`) into their Unicode equivalents (`½`, `¾`, `⅞`) in LayOut documents.

## ✨ Features

- **Labels** — direct in-place conversion
- **Text boxes** (FormattedText) — direct in-place conversion
- **Dimensions** — creates Unicode overlay text on a dedicated layer
- **Original file preserved** — saves output as `_UNICODE.layout`
- **Overlay layer** — "Fractions Unicode" layer for dimension overlays (toggle on/off)

## 📏 Supported Fractions

| Text | Unicode | Text | Unicode |
|------|---------|------|---------|
| 1/2  | ½       | 1/6  | ⅙       |
| 1/3  | ⅓       | 5/6  | ⅚       |
| 2/3  | ⅔       | 1/8  | ⅛       |
| 1/4  | ¼       | 3/8  | ⅜       |
| 3/4  | ¾       | 5/8  | ⅝       |
| 1/5  | ⅕       | 7/8  | ⅞       |
| 2/5  | ⅖       | 3/5  | ⅗       |
| 4/5  | ⅘       |      |         |

## 📥 Download

### Option 1: Download ZIP (Easiest)
1. Go to https://github.com/mariocha/LayOut-Unicode-fractions
2. Click the green **Code** button
3. Select **Download ZIP**
4. Extract the ZIP file to a temporary location
5. You'll find the needed files inside the extracted folder

### Option 2: Download Individual Files
1. **Download `mc_fraction_fixer.rb`:**
   - Go to https://github.com/mariocha/LayOut-Unicode-fractions/blob/main/mc_fraction_fixer.rb
   - Click the **Raw** button (or right-click → Save As)
   - Save the file to your computer

2. **Download `main.rb`:**
   - Go to https://github.com/mariocha/LayOut-Unicode-fractions/blob/main/mc_fraction_fixer/main.rb
   - Click the **Raw** button (or right-click → Save As)
   - Save the file to your computer
   - **Important:** Keep the folder structure! Create a folder named `mc_fraction_fixer` and put `main.rb` inside it

### Option 3: Git Clone (Advanced)
```bash
git clone https://github.com/mariocha/LayOut-Unicode-fractions.git
```

## 📦 Installation

1. After downloading (see above), you need these files:
   - `mc_fraction_fixer.rb`
   - `mc_fraction_fixer/main.rb`

2. Copy the following into your SketchUp Plugins folder:
   ```
   Plugins/
   ├── mc_fraction_fixer.rb
   └── mc_fraction_fixer/
       └── main.rb
   ```

3. **Plugins folder location:**
   - **Windows:** `C:\Users\<username>\AppData\Roaming\SketchUp\SketchUp 2026\SketchUp\Plugins\`
   - **macOS:** `~/Library/Application Support/SketchUp 2026/SketchUp/Plugins/`
   
   **Note:** On Windows, the `AppData` folder is hidden by default. To show it:
   - Open File Explorer
   - Click **View** → **Show** → **Hidden items**

4. Restart SketchUp

## 🚀 Usage

1. Open SketchUp Pro 2026
2. Go to **Plugins → Fraction Fixer → Convert LayOut File...**
3. Select a `.layout` file
4. Choose your conversion mode:
   - **OUI** — Converts labels & text + creates overlay texts for dimensions
   - **NON** — Converts labels & text only
5. A new file `yourfile_UNICODE.layout` is created (original is preserved)

## ⚙️ Requirements

- **SketchUp Pro 2026** (requires the `Layout` Ruby API module)

## 📄 License

© 2026 Mario Chabot