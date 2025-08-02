# 🔍 SearchApp

**SearchApp** is a lightweight, real-time search logger built with Ruby on Rails. It captures what users type into search fields—even before submission—and stores meaningful queries for analysis. This helps product teams understand user interest, trends, and behavior without building full search infrastructure.

---

## 🚀 Features

- ✅ Logs every submitted search phrase
- 💡 Suggestion endpoint based on user history
- 🔒 Anonymous tracking via IP (no accounts needed)
- ⌨️ Real-time event logging (Enter, Backspace, Tab close)
- 📊 Simple analytics dashboard
- 🧪 RSpec test suite with meaningful coverage

---

## 🧰 Tech Stack

- **Backend**: Ruby on Rails
- **Frontend**: Stimulus.js, Tailwind CSS
- **Database**: PostgreSQL
- **Containerization**: Docker & Docker Compose

---

## 🖥️ Running the App Locally

You'll need **Docker** and **Docker Compose** installed.

```bash
# 1. Clone the repo
git clone https://github.com/mostafasobh/search-app.git
cd search-app

# 2. Export the required environment variables
export HELPJUICE_DATABASE_PASSWORD=your_db_password
export RAILS_MASTER_KEY=your_rails_master_key

# 3. Build and run the app
docker-compose up --build

# 4. Visit the app at
http://localhost:3000
```

---

## 🧪 Running the Test Suite

```bash
# 1. Open a terminal inside the container
docker-compose exec app bash

# 2. Run RSpec tests
bundle exec rspec
```

All tests should pass if the app is set up correctly. Specs cover logging, query tracking, and edge cases.

---

## 📈 Analytics View

The app includes a simple dashboard to view submitted queries by volume and recency. This is helpful for internal product teams or content strategists.

---

## 📬 Get in Touch

Have questions, feedback, or want to critique the app?  
Feel free to open an issue or connect with me:

- 🐙 [GitHub Issues](https://github.com/mostafasobh/search-app/issues)
- 💼 [LinkedIn – Mostafa Sobh](https://www.linkedin.com/in/mostafa-sobh-3ba6531b2/)

I’d love to hear your thoughts, especially if you find this useful or want to contribute.


---

## ⭐️ Show Your Support

If you found this helpful or interesting, consider giving the repo a ⭐️ on GitHub — it helps others discover the project!
