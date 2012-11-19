from distutils.core import setup, Extension

module1 = Extension('audiopack',
                    sources = ['audiopack.c'])

setup (name = 'Audiopack',
       version = '0.1',
       ext_modules = [module1])
