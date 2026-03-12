from setuptools import setup, find_packages

setup(
    name="ProjectPotato",
    version="0.0.1",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "psutil",
        "pywin32",
		"discord.py",
    ],
	package_data={}
)