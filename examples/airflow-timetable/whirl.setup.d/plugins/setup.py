from setuptools import setup, find_packages

setup(
    name='custom-plugins',
    version='1.0.0',
    description='Airflow custom plugins',
    author='Kris Geusebroek',
    author_email='krisgeusebroek@godatadriven.com',
    packages=find_packages(include=['custom_plugins', 'custom_plugins.*']),
    install_requires=[
        'apache-airflow>=2.2.5',
        'ephem==4.1.5'
    ],
    entry_points={
        'airflow.plugins': [
            'fullmoon_timetable = custom_plugins.timetable.fullmoon:FullMoonTimetablePlugin'
        ]
    }
)
