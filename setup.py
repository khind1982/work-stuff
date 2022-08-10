import setuptools

setuptools.setup(
        name="c19index",
        version="0.1.0",
        author="CID Team",
        author_email="PQ-CBG-CID-Support@clarivate.com",
        description="Ingest transformation for C19 Index",
        packages=setuptools.find_packages(),
        install_requires=[
            'pqcoreutils',
            'lxml',
            ],
        dependency_links=[
            ],
        entry_points={
            'console_scripts': [],
            },
        classifiers=[
            "Programming Language :: Python :: 3",
            "License :: Other/Proprietary License",
            "Operating System :: POSIX",
            ],
        )
