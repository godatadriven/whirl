# TODO: replace with environment.yaml
conda create --name datahub python=3.9
conda activate datahub

python3 -m pip install --upgrade pip wheel setuptools
python3 -m pip install --upgrade acryl-datahub
pip install acryl-datahub-airflow-plugin
