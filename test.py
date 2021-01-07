import base64
from PIL import Image
thumbSize= (256, 256)
im = Image.open('T03.jpg')
im.thumbnail(thumbSize)
print(im.format)
print(im.size)
print(im.mode)

# with open("T03.jpg", "rb") as img_file:
#     my_string = base64.b64encode(img_file.read())
# print(my_string)