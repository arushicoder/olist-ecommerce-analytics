
import sqlite3
import os
import pandas as pd


class DatabaseManager:
    """Manage SQLite database and load Olist CSV datasets."""

    def __init__(self, database_name="olist.db"):
        self.database_name = database_name
        self.connection = None

        self.files = {
            "customers": "olist_customers_dataset.csv",
            "geolocation": "olist_geolocation_dataset.csv",
            "order_items": "olist_order_items_dataset.csv",
            "payments": "olist_order_payments_dataset.csv",
            "reviews": "olist_order_reviews_dataset.csv",
            "orders": "olist_orders_dataset.csv",
            "products": "olist_products_dataset.csv",
            "sellers": "olist_sellers_dataset.csv",
            "category_translation": "product_category_name_translation.csv"
        }

    def connect(self):
        """Connect to SQLite database."""

        self.connection = sqlite3.connect(self.database_name)
        print("SQLite database connected successfully!")

    def load_csv_tables(self, data_folder):
        """Load all available CSV files into SQLite tables."""

        if self.connection is None:
            raise RuntimeError("Connect to the database first.")

        loaded_tables = []
        missing_files = []

        for table_name, filename in self.files.items():
            file_path = os.path.join(data_folder, filename)

            if not os.path.exists(file_path):
                missing_files.append(filename)
                print(f"File not found: {filename}")
                continue

            try:
                df = pd.read_csv(file_path)

                df.to_sql(
                    table_name,
                    self.connection,
                    if_exists="replace",
                    index=False
                )

                loaded_tables.append(table_name)

                print(
                    f"Table created: {table_name} | Rows: {len(df)}"
                )

            except Exception as error:
                print(f"Error loading {filename}: {error}")

        print("\nDatabase loading summary")
        print("Tables loaded:", len(loaded_tables))
        print("Files missing:", len(missing_files))

        return loaded_tables

    def close(self):
        """Close the database connection."""

        if self.connection is not None:
            self.connection.close()
            self.connection = None
            print("Database connection closed.")


if __name__ == "__main__":
    db = DatabaseManager()

    try:
        db.connect()
        db.load_csv_tables("data/raw")

    finally:
        db.close()
