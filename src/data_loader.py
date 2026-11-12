
import pandas as pd
import os


class DataLoader:
    """
    Loads all 9 Olist CSV datasets and
    provides basic information about them.
    """

    def __init__(self, data_folder):
        self.data_folder = data_folder

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

        self.data = {}
        self.failed_files = []

    def load_data(self):
        """Load all CSV files into Pandas DataFrames."""

        for name, filename in self.files.items():
            file_path = os.path.join(self.data_folder, filename)

            try:
                self.data[name] = pd.read_csv(file_path)
                print(f"Successfully loaded: {filename}")

            except FileNotFoundError:
                self.failed_files.append(filename)
                print(f"File not found: {filename}")

        print("\nTotal datasets loaded:", len(self.data))
        print("Total files missing:", len(self.failed_files))

        return self.data

    def report(self):
        """Display shape, data types and missing values."""

        if not self.data:
            print("No datasets loaded. Please check the data folder.")
            return

        for name, df in self.data.items():
            print("\n" + "=" * 55)
            print(f"DATASET: {name.upper()}")
            print("=" * 55)

            print("\nDataset Shape:", df.shape)

            print("\nColumn Data Types:")
            print(df.dtypes)

            print("\nMissing Values:")
            print(df.isnull().sum())


if __name__ == "__main__":
    loader = DataLoader("data/raw")

    loader.load_data()
    loader.report()
