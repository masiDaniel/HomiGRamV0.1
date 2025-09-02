# Homigram Backend
> Django REST API for Homigram – a student rental management system.

---

##  Overview
The **Homigram backend** powers the rental management system with APIs for user authentication, property listings, chat, and rental agreements. It is built with Django and Django REST Framework, ensuring scalability and security.

---

##  Features
- JWT-based Authentication
- User management (Students & Landlords)
- Rental listings CRUD
- Real-time chat (WebSocket/REST fallback)
- Rental agreements management
- Location-based queries

---

## 🛠 Tech Stack
- **Framework:** Django, Django REST Framework
- **Database:** PostgreSQL / SQLite (dev)
- **Auth:** JWT
- **Deployment:** Gunicorn + Nginx (production)

---

##  Getting Started

### Prerequisites
- Python 3.0+
- pip & virtualenv
- PostgreSQL (or SQLite for local dev)

### Installation
```bash
# Clone repo
git clone https://github.com/masiDaniel/HomiGRamV0.1.git
cd HomieGramBackEnd/

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Apply migrations
python manage.py migrate

# Run server
python manage.py runserver
```
### Happy coding.