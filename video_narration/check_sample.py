import sys
sys.path.insert(0,r'C:\Users\giahu\.codex\visualizations\2026\11\02\01a19b4f-4125-7aa2-b948-42a39e3d3418\video_tools')
import cv2
from PIL import Image,ImageDraw
from pathlib import Path
c=cv2.VideoCapture(r'C:\Users\giahu\Downloads\Download.mp4')
d=c.get(7)/c.get(5)
print({'duration':d,'width':c.get(3),'height':c.get(4)})
sheet=Image.new('RGB',(1200,1160),'white')
draw=ImageDraw.Draw(sheet)
for i,t in enumerate([20,25,35,40,45,50,55,60]):
    c.set(cv2.CAP_PROP_POS_MSEC,t*1000)
    ok,f=c.read()
    if ok:
        im=Image.fromarray(cv2.cvtColor(f,cv2.COLOR_BGR2RGB))
        im.thumbnail((300,700))
        sheet.paste(im,((i%4)*300,(i//4)*580+35))
        draw.text(((i%4)*300+5,(i//4)*580+10),str(round(t,2))+' s',fill='black')
sheet.save(Path(__file__).parent/'tiktok_sample.jpg')
c.release()
