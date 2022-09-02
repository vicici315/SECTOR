
import random,math,pyperclip
def GridNum(Num):
    a = []
    over = ''
    rn = Num*Num
    for i in range(rn):
        a.append(i+1)
    for o in range(5):
        random.shuffle(a)
    c = 0
    for n in a:
        c += 1
        if c % math.sqrt(rn) == 0:
            if c < rn:
                over+=str(n)+'\n'
            else:
                over+=str(n)
            print(n, end='\n')
        else:
            over+=str(n)+'\t'
            print(n, end='\t')
    return over

qu='y'
while qu=='y':
    nn = input('输入格子行数:')
    pyperclip.copy(GridNum(int(nn)))
    print('随机数已复制到剪贴板')
