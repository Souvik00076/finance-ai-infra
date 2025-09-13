![High Level Design](https://github.com/Souvik00076/my-all-gifs/blob/master/design.gif)
<p align="center">
  <a href="https://github.com/Souvik00076/finance-ai-backend">
    <img src="https://img.shields.io/badge/Visit%20Backend%20Code-Click%20Here-blue?style=for-the-badge"/>
  </a>
</p>


## 💡 Project Motivation

We all want to track our expenses… but opening an app every time we spend feels like a chore. Slowly, we stop doing it — and by the end of the month, we’re left wondering:  
**“Where did all my money go?”** 💸

So I thought — what if expense tracking was as simple as sending a WhatsApp message?  
No new app. No friction. Just type it out like you would text a friend.  
That’s how this project was born. 🚀

---

## ⚙️ Tech Stack & Architecture

This project combines messaging simplicity with backend intelligence:

| Component            | Role                                                                 |
|----------------------|----------------------------------------------------------------------|
| **Twilio + WhatsApp**| Users send expense messages via WhatsApp                             |
| **Hookdeck**         | Manages and retries webhooks reliably                                |
| **Node.js Backend**  | Parses and processes incoming expense data                           |
| **RabbitMQ**         | Controls access to Gemini API for scalable insight generation        |
| **LangChain.js + Gemini** | Analyzes expenses and generates financial insights ✨         |
| **MongoDB Atlas**    | Secure cloud storage for all expense records                         |
| **React Dashboard**  | (In progress) Visualizes insights and trends beautifully 📊          |
| **Nginx Load Balancer** | Configured with 2-step rate limiting for request control       |
| **Docker Compose**   | Mimics a production-grade environment with scaled service instances  |

---

## 🚀 Current Status

✅ Core functionality is complete  
✅ Backend deployment setup is live and stable  
✅ Nginx load balancer configured with dual-layer rate limiting  
✅ Scaled services using Docker Compose to mimic production environment  
🔧 React dashboard is under development

---

## 🛠️ How to Run Locally

To run the project locally, follow these steps:

### 1️⃣ Create a `.env` file in the root directory with the following variables:

> ⚠️ **Important:** Replace sensitive values with your own credentials. Never commit `.env` files to version control.

```env
RABBIT_MQ_DEFAULT_USER=guest
RABBIT_MQ_PASS=guest
MONGO_URI="your-mongodb-uri"
RABBIT_MQ_URL=amqp://guest:guest@rabbitmq:5672
PORT=8000
HD_SIG=your-hookdeck-signature
