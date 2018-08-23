import cv2
import re
import pytesseract
img=cv2.imread('C:\\Users\\Jatin\\Desktop\\Number Plate Detection through OCR\\test.jpg')
b = 70# brightness
c = 35  # contrast
img = cv2.addWeighted(img, 1. + c/127., img, 0, b-c)
#imgBlurred = cv2.GaussianBlur(img, (5,5), 0)
text = pytesseract.image_to_string(img, lang = 'eng')
match=re.findall(r'[A-Z|0-9]{10}',text)
if(match==[]):
    txt=None
else:
    #print(match[0])
    y=[0]*(len(match[0]))
    for i in range(0,len(match[0])):
        if(i==0 and match[0][i]=='0'):
            y[i]='O'
        elif(i>=2 and i<=3 and match[0][i]=='O'):
            y[i]='0'
        elif(i>=(len(match[0]))-4 and i<len(match[0]) and match[0][i]=='O' ):
            y[i]='0'
        else:
            y[i]=match[0][i]
    #print(y)
    x=''.join(y)
    txt=x[0:2]+'-'+x[2:]
    print(txt)

def main():
    print('')
    
if __name__ == "__main__":
    main()
