from sqlalchemy import create_engine, text
server = "localhost"
database = "Bokhandel1DB"
username = "sa"
password = "StrongPass123!"

connection_string = (

    f"mssql+pyodbc://{username}:{password}@{server}/{database}"
    "?driver=ODBC+Driver+18+for+SQL+Server"
    "&TrustServerCertificate=yes"
)

engine = create_engine(connection_string)

search_text = input("Sök efter en boktitel: ")

query = text("""
SELECT
b.Titel,
b.ISBN13,
b.Pris,
bu.Butiksnamn,
ls.Antal
FROM Böcker b
JOIN Lagersaldo ls
    ON b.ISBN13 = ls.ISBN
JOIN Butiker bu
    ON ls.ButikID = bu.ID
WHERE b.Titel LIKE :search
ORDER BY b.Titel, bu.Butiksnamn                   
""")

with engine.connect() as conn:
    result = conn.execute(
        query,
        {"search" : f"%{search_text}%"}
    )

    print("\nResultat:\n")

    found = False

    for row in result:
        found = True

        print(

            f"Bok: {row.Titel}\n"

            f"ISBN: {row.ISBN13}\n"

            f"Pris: {row.Pris} kr\n"

            f"Butik: {row.Butiksnamn}\n"

            f"Antal i lager: {row.Antal}\n"

        )

    if not found:

        print("Inga böcker hittades.")

