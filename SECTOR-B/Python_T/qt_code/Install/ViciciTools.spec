# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['c:\\Tongbu\\Works\\Experiment\\Python_T\\qt_code\\RenamerMain.py'],
             pathex=['C:\\Tongbu\\Works\\Experiment\\Python_T\\qt_code\\Install'],
             binaries=[],
             datas=[],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='ViciciTools',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=False , icon='c:\\Tongbu\\Works\\Experiment\\Python_T\\qt_code\\victools.ico')
