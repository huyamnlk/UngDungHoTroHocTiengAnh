import sys, math, json
from pathlib import Path
sys.path.insert(0, r'C:\Users\giahu\.codex\visualizations\2026\11\02\01a19b4f-4125-7aa2-b948-42a39e3d3418\video_tools')
import cv2
from PIL import Image, ImageDraw, ImageFont

video = r'C:\Users\giahu\Videos\Screen Recordings\Screen Recording 2026-11-02 211524.mp4'
out = Path(__file__).parent
cap = cv2.VideoCapture(video)
duration = cap.get(cv2.CAP_PROP_FRAME_COUNT) / cap.get(cv2.CAP_PROP_FPS)
times = list(range(0, math.ceil(duration), 5)) if len(sys.argv)==1 else [float(x) for x in sys.argv[1:]]
font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 24)
for batch in range(0,len(times),12):
    subset=times[batch:batch+12]
    sheet=Image.new('RGB',(1920,390*math.ceil(len(subset)/3)), '#e8e8e8')
    draw=ImageDraw.Draw(sheet)
    for i,t in enumerate(subset):
        cap.set(cv2.CAP_PROP_POS_MSEC,t*1000)
        ok,frame=cap.read()
        if not ok: continue
        im=Image.fromarray(cv2.cvtColor(frame,cv2.COLOR_BGR2RGB))
        if len(sys.argv)>1: im.save(out/f'frame_{t:07.2f}.jpg',quality=92)
        im.thumbnail((640,360))
        x=(i%3)*640; y=(i//3)*390
        sheet.paste(im,(x,y+30))
        draw.text((x+10,y+2),f'{int(t)//60:02d}:{int(t)%60:02d} ({t:g}s)',font=font,fill='black')
    name=f'contact_{batch//12:02d}.jpg' if len(sys.argv)==1 else f'detail_{times[batch]:g}.jpg'
    sheet.save(out/name,quality=88)
print(json.dumps({'duration':duration,'frames_sampled':len(times),'sheets':math.ceil(len(times)/12)}))
cap.release()
