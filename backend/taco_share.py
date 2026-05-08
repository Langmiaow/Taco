from flask import Flask, request, jsonify
import sqlite3
import hashlib
import random
import time


app = Flask(__name__)

DB_PATH = "taco.db"

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS taco_share (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pin TEXT NOT NULL UNIQUE,
        todo_hash TEXT NOT NULL UNIQUE,
        content TEXT NOT NULL,
        remark TEXT,
        ddl INTEGER,
        created_at INTEGER NOT NULL
    )
    
    """)
    conn.commit()
    conn.close()

def toHash(content: str, remark: str, ddl) -> str:
    base = f"{content}|{remark}|{ddl}"
    return hashlib.sha256(base.encode("utf-8")).hexdigest()


def generate_pin(conn, max_try=50) -> str:
    cur = conn.cursor()
    for _ in range(max_try):
        pin = f"{random.randint(0, 9999):04d}"
        cur.execute("SELECT 1 FROM taco_share WHERE pin = ?", (pin,))
        if cur.fetchone() is None:
            return pin
    raise RuntimeError("PIN collisions too many times")

@app.post("/api/share")
def share():
    data = request.get_json(silent=True)

    if not data:
        return jsonify({
            "done": False,
            "error": "No data received"
        }), 400
    
    content = data.get("content", "").strip()
    remark = data.get("remark", "").strip()
    ddl = data.get("ddl")

    todo_hash = toHash(content, remark, ddl)

    conn = get_db()
    cur = conn.cursor()

    cur.execute("SELECT pin FROM taco_share WHERE todo_hash = ?", (todo_hash,))
    row = cur.fetchone()
    if row is not None:
        conn.close()
        return jsonify({
            "done": True,
            "pin": row["pin"],
            "duplicate": True
        }), 200
    
    pin = generate_pin(conn)

    cur.execute("""
        INSERT INTO taco_share (pin, todo_hash, content, remark, ddl, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        pin,
        todo_hash,
        content,
        remark,
        ddl,
        int(time.time())
    ))
    conn.commit()
    conn.close()

    print("User requiring to share taco ", data)

    return jsonify({
        "done": True,
        "pin": pin
    }), 200

@app.get("/api/share/<pin>")
def get_shared(pin):
    conn = get_db()
    cur = conn.cursor()

    cur.execute(
        "SELECT content, remark, ddl FROM taco_share WHERE pin = ?",
        (pin,)
    )
    row = cur.fetchone()
    conn.close()

    if not row:
        return jsonify({"done": False, "error": "pin not found"}), 404

    return jsonify({
        "done": True,
        "content": row["content"],
        "remark": row["remark"] or "",
        "ddl": row["ddl"],
    }), 200




import os

init_db()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)),debug=False)