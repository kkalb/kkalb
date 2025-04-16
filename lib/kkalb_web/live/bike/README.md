# 🧠 Small game app enhancements & TODOs

Here's a quick overview of the current goals and potential enhancements.

The goal is to guess a random number between 1 and n, where n is set at compile time to 5.

---

## 🚀 Getting Started

To start the server, run the following command:

## 🔥Important note
 Everything was developed and tested in devcontainer in vscode.
 To ensure everything works on other setups, please use devcontainers or 

```bash
mix setup
MIX_ENV=dev mix ecto.reset
DISABLE_SCHEDULING=true mix bravo
```

---

## 🛠️ To-Dos

### 🧹 Backend Improvements
- **Sanitize & Normalize Usernames**  
  Convert all usernames to lowercase and clean up input before storing in the DB. (WIP - added unique contraint to changeset)

- **Form Error Handling**
  Improve error visibility and feedback for form submissions.
  (WIP - added flash msgs)
- **Game Logic Refactor**  
  Decouple game logic from `LiveView` for better testability and scalability.
  (WIP)

### 🎯 Highscore Management
- **Refactor Highscore Storage**  
  - Option 1: Move highscores into a separate dedicated table.  
  - Option 2: Make highscore field nullable within the user schema.
- Make highscores and users deleteable 

### 🎨 UI/UX Enhancements
- ~~Refresh design and improve user experience across the app.~~

---

## 📌 Notes
- Development currently assumes scheduling is disabled using the `DISABLE_SCHEDULING=true` flag.
- This way you do not need to provide any API_KEY that the overall system requires (besides bravo game).
- ~~The hosted webside currently has no DB since it is too expensive. Maybe I rent one for a month later. Do not wonder if it does not work in the production system.~~

---
