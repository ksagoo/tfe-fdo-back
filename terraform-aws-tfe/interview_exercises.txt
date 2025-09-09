"""
Python Debugging Interview — All-in-One Script Version

- Each exercise is defined as exercise1(), exercise2(), ... exercise14().
- Uncomment ONE call at the bottom to run it.
- Candidate should run, observe the error/buggy behavior, and then fix live.

Includes:
  Warm-up: exercises 1–5
  Bonus: exercises 6–14
"""

def exercise1():
    def greet(name):
print("Hello,", name)   # <- indentation issue

    greet("Ada")

def exercise2():
    def add_numbers(a, b):
        return a + c   # <- undefined variable

    print(add_numbers(2, 3))

def exercise3():
    age = "25"
    print(age + 5)   # <- type mismatch

def exercise4():
    def is_even(n):
        return n % 2 == 1   # <- logic bug

    print("2 is even?", is_even(2))
    print("3 is even?", is_even(3))

def exercise5():
    def append_item(item, items=[]):
        items.append(item)
        return items

    print("First call:", append_item("a"))
    print("Second call:", append_item("b"))  # <- shared list surprise

def exercise6():
    def read_config(path):
        f = open(path)            # may leak if parse() raises
        data = parse(f.read())    # parse is undefined here
        f.close()
        return data

    try:
        read_config("config.txt")
    except Exception as e:
        print(type(e).__name__, e)

def exercise7():
    import csv

    def save_rows(path, rows):
        f = open(path, "w")  # missing newline/encoding/context manager
        writer = csv.writer(f)
        for r in rows:
            writer.writerow(r)
        f.close()

    save_rows("out.csv", [["naïve", "café"], ["a", "b"]])
    print("Wrote out.csv — check for blank lines/encoding issues.")

def exercise8():
    import asyncio, time

    async def fetch(i):
        time.sleep(0.1)  # blocks event loop
        return i

    async def main():
        tasks = [fetch(i) for i in range(5)]
        results = asyncio.gather(*tasks)  # not awaited
        print("Finished? (tasks may not have run)")
        return results

    try:
        asyncio.run(main())
    except Exception as e:
        print(type(e).__name__, e)

def exercise9():
    import threading

    global counter
    counter = 0

    def work(n):
        global counter
        for _ in range(n):
            counter += 1  # data race

    threads = [threading.Thread(target=work, args=(100_000,)) for _ in range(4)]
    for t in threads: t.start()
    for t in threads: t.join()
    print("Final counter:", counter, "Expected:", 400_000)

def exercise10():
    import sqlite3
    conn = sqlite3.connect(":memory:")
    cur = conn.cursor()
    cur.execute("CREATE TABLE users (id INT, name TEXT)")
    cur.execute("INSERT INTO users VALUES (1, 'O\\'Malley')")

    username = "O'Malley"
    query = f"SELECT id, name FROM users WHERE name = '{username}'"
    print("Running:", query)  # breaks on quotes and is injectable
    try:
        cur.execute(query)
        print(cur.fetchone())
    except Exception as e:
        print(type(e).__name__, e)

def exercise11():
    from datetime import datetime, timedelta

    start = datetime.now()              # naive
    end = start + timedelta(hours=24)
    print("Seconds diff:", (end - start).total_seconds())  # assumes 86400

def exercise12():
    def process(lines_iter):
        return [s.strip() for s in lines_iter if s.strip()]

    data = iter(["a\\n", "\\n", "b\\n"])
    first = process(data)
    second = process(data)  # empty: iterator consumed
    print("first:", first, "second:", second)

def exercise13():
    from dataclasses import dataclass

    @dataclass
    class Cart:
        items: list = []   # shared across instances

    c1 = Cart()
    c2 = Cart()
    c1.items.append("x")
    print("c2.items:", c2.items)  # unexpected shared list

def exercise14():
    import logging
    API_KEY = "sk_live_example_secret_value"  # pretend secret

    def charge(amount_pennies):
        try:
            raise TimeoutError("simulated")
        except Exception as e:
            logging.error("Charge failed for key=%s amount=%s err=%r", API_KEY, amount_pennies, e)
            return False

    print("Result:", charge(1234))

if __name__ == "__main__":
    # Uncomment ONE exercise to run it:
    # exercise1()
    # exercise2()
    # exercise3()
    # exercise4()
    # exercise5()
    # exercise6()
    # exercise7()
    # exercise8()
    # exercise9()
    # exercise10()
    # exercise11()
    # exercise12()
    # exercise13()
    # exercise14()
    pass
