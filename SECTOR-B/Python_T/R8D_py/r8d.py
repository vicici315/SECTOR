import random,math,pyperclip

def CreateCode(ID):
    STRINGS = 'CBuFGIJZglNOefaPH_+UVWX%^&*(Y}:b3,5c~E@d6{Mhijkno[pqL4vA$)rstwDm-#xKyR!Sz17Q0T89=`2].;'
    CODEsssM = 'QWERT45TYUIOPLDGHKJ-HGFD-GSAMGHNBVCXSZ543126TH78J9J0P3QRZWSX-PLMOKNIJ6BU-HYGVTFRDCEXW8'

    strID = ID
    Aa = ''
    Bb = ''
    AB = ''
    ONES = ''
    
    CPNnum = []
    if len(strID) <= 2:
        strID = strID + 'aSR'
    for i in range(len(strID)):
        ONES = strID[i:i+1]
        CNum = STRINGS.index(ONES)
        CPNnum.append(CNum)
    Ccodekey = SC = ''
    for i in CPNnum:
        SC = CODEsssM[i:i+1]
        Ccodekey = (Ccodekey+SC)
    ckN = len(Ccodekey)
    if ckN <= 40:
        TTs = int(ckN / 2)
        Aa = Ccodekey[TTs-1:]
        Bb = Ccodekey[0:TTs]
        Pnum = int(len(CPNnum)/2-1)
        CPnum = CPNnum[Pnum]
        end = 0
        codeL = len(CODEsssM)
        if CPnum + (40-ckN) > codeL:
            end = codeL-CPnum-1
        else:
            end = 40-ckN
        AB = CODEsssM[CPnum:CPnum+end]
        Ccodekey = Aa+AB+Bb
    print(Ccodekey)
    return Ccodekey

qu='y'
while qu=='y':
    nn = input('ID:')
    pyperclip.copy(CreateCode(nn))
    print('已复制到剪贴板')
