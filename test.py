import os
from cryptography.fernet import Fernet
from configparser import ConfigParser
conf = ConfigParser()
setPath = os.getcwd()+'\\PrinterSetting.ini'
pcount = 0
if os.path.exists(setPath):
    conf.read_file(open(setPath, encoding='utf-8'))
if not conf.has_section('SETTINGS'):
    conf.add_section('SETTINGS')

# 生成随机密钥
key = Fernet.generate_key()

# 自定义密钥
key = b'j49uKF1BZJrxFoq6pp-g4_jH8azUwzpN8MZM3O4aATc='
# key = b'YTEyYXNkZmI='
cipher_suite = Fernet(key)


# 加密整数参数
dblod = '1'
encrypted_integer = cipher_suite.encrypt(dblod.encode('utf-8'))
print(f"Encrypted Integer: {encrypted_integer}")
conf.set('SETTINGS','dbid2',str(encrypted_integer.decode('utf-8'))) #转换为字符串并保存
conf.write(open(setPath, 'w+', encoding='utf-8'))


# 解密整数参数
# dblod = conf.get('SETTINGS','dbid2')
# dblod=dblod.encode('utf-8')
# decrypted_integer = int(cipher_suite.decrypt(dblod))
# print(f"Decrypted Integer: {decrypted_integer}")

