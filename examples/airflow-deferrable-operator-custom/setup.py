import setuptools

setuptools.setup(
    name="custom",
    version="0.1",
    description="Package containing custom Airflow components",
    packages=setuptools.find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=["apache-airflow~=3.0"],
    setup_requires=["wheel"],
    python_requires=">=3.10",
)
