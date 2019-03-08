FROM atlassianlabs/localstack:0.6.2


# Monkeypatch moto to deliver 1 line XML responses that spark can handle
RUN sed -i.bak 's#self.loader.update({template_id: source})#collapsed = "".join(line.strip() for line in source.split("\\n"))\n            self.loader.update({template_id: collapsed})#g' /opt/code/localstack/.venv/lib/python2.7/site-packages/moto/core/responses.py
