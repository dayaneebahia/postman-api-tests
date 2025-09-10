
# postman-api-tests

Testes de API utilizando **Postman + Newman**, com **pipeline CI/CD** no **GitHub Actions**.

## Visão geral

Este repositório contém coleções do Postman e um fluxo de CI para executar os testes manual para as branches  `develop`.
Os resultados em **JUnit (results.xml)** são publicados como **artefatos** do workflow.

## Estrutura

```
.
├─ collections/               # Coleções e ambientes do Postman
│  ├─ example_collection.json
│  └─ example_environment.json
├─ .github/workflows/
│  └─ ci.yml                  # Pipeline do GitHub Actions (Newman)
├─ docker-compose.yml         # Execução via container 
├─ results.xml                # Saída JUnit (local / CI)
└─ README.md
```

## Pré-requisitos

* **Node.js 18+** (para rodar Newman localmente)
* **Docker** e **Docker Compose** (opcional)
* **Git** e uma conta no **GitHub**
* (Recomendado) **nvm** para gerenciar a versão do Node

##  Como rodar **localmente** (Newman)

Instale o Newman e execute os testes com a sua coleção/ambiente:

```bash
# instalar newman globalmente
npm install -g newman

# rodar a coleção (ajuste paths conforme seu repo)
newman run collections/example_collection.json \
  --environment collections/example_environment.json \
  --reporters cli,junit \
  --reporter-junit-export results.xml
```

* O relatório **JUnit** será salvo em `results.xml`.
* Se sua API precisa de **variables/secrets**, use um arquivo de ambiente do Postman (JSON) e **NÃO** commite segredos.
  Use `{{VAR_NAME}}` na collection e forneça os valores só no env local ou via **GitHub Secrets**.

## 🐳 Como rodar com **Docker**

```bash
docker compose up --build --exit-code-from newman
```

* Ajuste o serviço no `docker-compose.yml` para apontar para a sua coleção/ambiente.
* O container fará o build e executará o Newman.

##  CI com **GitHub Actions**

O workflow em `.github/workflows/ci.yml` executa:

1. **checkout** do repositório
2. **setup-node**
3. **instalação** do newman
4. **execução** dos testes (collection + environment)
5. **upload** do arquivo `results.xml` como **artifact**

Dispara em:

```yaml
on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main" ]
```

### 🔎 Onde ver os resultados

* Aba **Actions** do repositório → selecione a execução → **Artifacts** → baixe `junit-results`.
* Logs detalhados ficam nos steps do job.

##  Secrets 

Adicione tokens/variáveis sensíveis em:
**Settings → Secrets and variables → Actions → New repository secret**
E consuma no workflow:

```yaml
env:
  API_TOKEN: ${{ secrets.API_TOKEN }}
```

No Postman, passe via env/headers usando `{{API_TOKEN}}`.

## Fluxo de branches

* **main**: branch estável (proteja exigindo PR).
* **develop**: integração das features antes de ir para `main`.
* **feature branches**: `feat/ci-postman`, `fix/...`, etc. → sempre via **PR**.

##  Convenção de commits (sugerido)

Use *Conventional Commits*:

* `feat:` nova funcionalidade
* `fix:` correção de bug
* `docs:` documentação
* `ci:` pipeline/Actions
* `test:` testes
* `chore:` tarefas de manutenção
  Ex.: `ci: aciona pipeline em push/PR para main e develop`

##  Dicas para testes

* Separe **coleção** e **ambiente** por contexto: `dev`, `staging`, `prod`.
* Use **pre-request scripts** e **tests** do Postman para criar dados e validar respostas.
* Gere **report JUnit** para integrar com ferramentas de qualidade.

##  Badges (opcional)

Depois do primeiro run do Actions, adicione um badge no topo do README:

```markdown
![CI](https://github.com/<USUARIO>/<REPO>/actions/workflows/ci.yml/badge.svg)
```

##  Segurança

* Nunca commit seu **Personal Access Token** (PAT).
* Se expôs um token em `git remote -v`, **revogue** em **Developer settings** e troque a URL:

```bash
git remote set-url origin https://github.com/<USUARIO>/<REPO>.git
```
