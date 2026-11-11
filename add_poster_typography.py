import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import numpy as np

def patch_background_scoreboard_to_2027(img):
    """
    Seamlessly replaces '2026' with '2027' on the background arena scoreboard,
    ensuring all 4 digits '2 0 2 7' have identical font, size, weight, tracking,
    rotation, and glowing cyan/white style.
    Global crop coordinates: x=100..320, y=240..420
    """
    W, H = img.size
    
    # Crop the local screen region
    crop_x0, crop_y0, crop_x1, crop_y1 = 100, 240, 320, 420
    crop = img.crop((crop_x0, crop_y0, crop_x1, crop_y1)).convert("RGB")
    arr = np.array(crop, dtype=float)
    
    # Inpaint the entire '2026' line (in crop coords: x=68..190, y=122..172)
    x0, x1 = 68, 190
    y0, y1 = 122, 172
    
    for y in range(y0, y1):
        v_weight = (y - y0) / (y1 - y0)
        for x in range(x0, x1):
            h_weight = (x - x0) / (x1 - x0)
            h_val = (1 - h_weight) * arr[y, x0 - 1] + h_weight * arr[y, x1]
            v_val = (1 - v_weight) * arr[y0 - 1, x] + v_weight * arr[y1, x]
            arr[y, x] = 0.5 * h_val + 0.5 * v_val
            
    np.random.seed(42)
    noise = np.random.normal(0, 1.2, arr[y0:y1, x0:x1].shape)
    arr[y0:y1, x0:x1] = np.clip(arr[y0:y1, x0:x1] + noise, 0, 255)
    
    clean_screen = Image.fromarray(np.uint8(arr)).convert("RGBA")
    
    # 4x upsampling for rendering
    scale = 4
    up_w, up_h = clean_screen.size[0] * scale, clean_screen.size[1] * scale
    up_screen = clean_screen.resize((up_w, up_h), Image.Resampling.LANCZOS)
    
    try:
        font = ImageFont.truetype("C:/Windows/Fonts/ariblk.ttf", 118)
    except:
        font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 120)
        
    txt_img = Image.new("RGBA", (800, 300), (0, 0, 0, 0))
    t_draw = ImageDraw.Draw(txt_img)
    
    chars = ["2", "0", "2", "7"]
    cx = 30
    for ch in chars:
        t_draw.text((cx, 30), ch, font=font, fill=(255, 255, 255, 255))
        bbox = t_draw.textbbox((cx, 30), ch, font=font)
        char_w = bbox[2] - bbox[0]
        cx += char_w + 18
        
    cropped_txt = txt_img.crop(txt_img.getbbox())
    rot = cropped_txt.rotate(-7.2, resample=Image.Resampling.BICUBIC, expand=True)
    
    # Cyan outer glow
    glow = rot.filter(ImageFilter.GaussianBlur(radius=5))
    g_arr = np.array(glow)
    g_arr[:, :, 0] = (g_arr[:, :, 0] * 0.35).astype(np.uint8)
    g_arr[:, :, 1] = (g_arr[:, :, 1] * 0.85).astype(np.uint8)
    g_arr[:, :, 2] = (g_arr[:, :, 2] * 1.0).astype(np.uint8)
    cyan_glow = Image.fromarray(g_arr)
    
    # Composite onto 4x screen
    pos_x = 352
    pos_y = 484
    up_screen.alpha_composite(cyan_glow, (pos_x, pos_y))
    up_screen.alpha_composite(rot, (pos_x, pos_y))
    
    final_crop = up_screen.resize(crop.size, Image.Resampling.LANCZOS)
    
    # Paste back onto full image
    full_patched = img.convert("RGBA")
    full_patched.paste(final_crop, (crop_x0, crop_y0))
    return full_patched

def update_poster_english():
    base_path = "11_Research_Progs/02_UAV_Contest_2027/uav_contest_2026_poster.jpg"
    out_path = "11_Research_Progs/02_UAV_Contest_2027/uav_contest_2027_poster_final.jpg"
    artifact_path = "C:/Users/T14/.gemini/antigravity/brain/d09db319-d5c5-4793-b835-f02c8c34fb77/uav_contest_2027_poster_final.jpg"
    
    # 1. Patch the background scoreboard from 2026 to 2027
    raw_img = Image.open(base_path).convert("RGB")
    patched_img = patch_background_scoreboard_to_2027(raw_img)
    
    W, H = patched_img.size # 896 x 1200
    
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    # Fonts
    font_bold_path = "C:/Windows/Fonts/segoeuib.ttf"
    font_reg_path = "C:/Windows/Fonts/segoeui.ttf"
    
    font_org = ImageFont.truetype(font_bold_path, 22)
    font_title = ImageFont.truetype(font_bold_path, 54)
    font_subtitle = ImageFont.truetype(font_bold_path, 22)
    font_date_badge = ImageFont.truetype(font_bold_path, 32)
    font_venue = ImageFont.truetype(font_bold_path, 19)
    font_anniv = ImageFont.truetype(font_reg_path, 17)
    
    # Top Header Gradient Bar
    for y in range(180):
        if y < 110:
            alpha = 250
        else:
            alpha = int(250 * (1 - (y - 110) / 70))
        draw.line([(0, y), (W, y)], fill=(10, 17, 36, alpha))
        
    # Top organization name: "TON DUC THANG UNIVERSITY"
    org_text = "TON DUC THANG UNIVERSITY"
    draw.text((W/2, 26), org_text, font=font_org, fill=(186, 230, 253, 255), anchor="mt")
    
    title_text = "UAV CONTEST 2027"
    # drop shadow
    draw.text((W/2 + 2, 58 + 2), title_text, font=font_title, fill=(0, 0, 0, 220), anchor="mt")
    draw.text((W/2, 58), title_text, font=font_title, fill=(6, 182, 212, 255), anchor="mt") # Cyber Cyan
    
    sub_text = "AUTONOMOUS LOW-ALTITUDE LOGISTICS ECOSYSTEM"
    draw.text((W/2, 120), sub_text, font=font_subtitle, fill=(245, 158, 11, 255), anchor="mt") # Amber
    
    # Bottom Badge for Date & Location (In English)
    box_w = 820
    box_h = 175
    box_x0 = (W - box_w) / 2
    box_y0 = H - box_h - 32
    box_x1 = box_x0 + box_w
    box_y1 = box_y0 + box_h
    
    draw.rectangle([box_x0 - 10, box_y0 - 5, box_x1 + 10, H], fill=(10, 17, 34, 230))
    draw.rounded_rectangle([box_x0, box_y0, box_x1, box_y1], radius=18, fill=(10, 22, 48, 245), outline=(6, 182, 212, 240), width=3)
    
    # Date Pill
    pill_w = 660
    pill_h = 52
    pill_x0 = (W - pill_w) / 2
    pill_y0 = box_y0 + 16
    draw.rounded_rectangle([pill_x0, pill_y0, pill_x0 + pill_w, pill_y0 + pill_h], radius=12, fill=(245, 158, 11, 245))
    
    date_text = "COMPETITION DATES: 20, 21 - 09 - 2027"
    draw.text((W/2, pill_y0 + pill_h/2), date_text, font=font_date_badge, fill=(15, 23, 42, 255), anchor="mm")
    
    venue_text = "VENUE: TDTU MULTI-PURPOSE SPORTS ARENA, HO CHI MINH CITY"
    draw.text((W/2, box_y0 + 88), venue_text, font=font_venue, fill=(240, 248, 255, 255), anchor="mt")
    
    anniv_text = "Celebrating the 30th Anniversary of Ton Duc Thang University (1997 - 2027)"
    draw.text((W/2, box_y0 + 122), anniv_text, font=font_anniv, fill=(148, 163, 184, 255), anchor="mt")
    
    # Composite overlay onto patched image
    final_img = Image.alpha_composite(patched_img, overlay).convert("RGB")
    final_img.save(out_path, quality=95)
    final_img.save(artifact_path, quality=95)
    print("Poster with uniform UAV CONTEST 2027 scoreboard successfully generated at:", out_path)

if __name__ == "__main__":
    update_poster_english()
