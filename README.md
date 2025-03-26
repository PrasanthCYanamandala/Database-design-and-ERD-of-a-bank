# Rich Bank Corporation Database Design  

## 📌 Project Overview  
This project is a **database design** for the **Rich Bank Corporation**, a financial institution catering to high-net-worth individuals. It was developed as part of the **Database Foundations** course at the **University of Texas at Dallas, Naveen Jindal School of Management** under the guidance of **Dr. Gasan Elkhodari**.  

The project defines **entities, attributes, business rules, relationships, and an ER diagram** to establish an optimized **database schema** for managing banking operations effectively.  

---

## 📂 Contents  
- **Business Rules**: Defines key constraints and relationships between entities.  
- **Entity Descriptions**: Detailed attributes of each database entity.  
- **ER Diagram**: Visual representation of entity relationships.  
- **Assumptions & Constraints**: Design limitations and considerations.  

---

## 🏦 Business Rules  
1️⃣ A **BANK** must hire **only one** AUDITOR.  
2️⃣ An **AUDITOR** can be hired by **at least one** BANK.  
3️⃣ A **BANK** must maintain **at least one** ACCOUNT.  
4️⃣ A **CUSTOMER** must hold **at least one** ACCOUNT.  
5️⃣ An **ACCOUNT** may manage **zero or many** DEBIT CARDS.  
6️⃣ A **PLATINUM CARD** is a **subtype** of DEBIT CARD.  

---

## 🏗️ Entity & Attribute Descriptions  
### **CUSTOMER**  
- `cust_id` (PK) - Unique identifier for each customer  
- `cust_fname` - First name  
- `cust_lname` - Last name  
- `cust_contact` - Email & phone number  
- `cust_address` - Residential address  

### **BANK**  
- `bank_code` (PK) - Unique branch code  
- `bank_name` - Name of the bank  
- `bank_contact` - Contact details  
- `bank_timings` - Operating hours  
- `bank_address` - Location details  

### **ACCOUNT**  
- `acc_number` (PK) - Unique account number  
- `cust_id` (FK) - Customer owning the account  
- `bank_code` (FK) - Bank managing the account  
- `acc_type` - Checking, savings, etc.  
- `acc_balance` - Account balance  
- `acc_status` - Active/inactive  

### **AUDITOR**  
- `aud_ID` (PK) - Unique auditor ID  
- `aud_fname` - First name  
- `aud_lname` - Last name  
- `aud_contact` - Email & phone number  
- `aud_address` - Auditor's location  
- `bank_code` (FK) - Bank branch audited  

### **DEBIT CARD**  
- `card_number` (PK) - Unique debit card number  
- `card_type` - Standard, Platinum, etc.  
- `card_provider` - Visa, MasterCard, etc.  
- `card_expiry` - Expiration date  
- `card_CVV` - Security code  
- `acc_number` (FK) - Linked account  

### **PLATINUM CARD (Subtype of Debit Card)**  
- `card_number` (PK) - Unique platinum card number  
- `cardholder_name` - Name on card  
- `atm_withdrawal_limit` - Max ATM withdrawal  
- `reward_points` - Earned reward points  

---

## 🔗 Relationship & Cardinality  
1️⃣ **BANK** ➝ **AUDITOR** → (M:1)  
2️⃣ **BANK** ➝ **ACCOUNT** → (1:M)  
3️⃣ **CUSTOMER** ➝ **ACCOUNT** → (1:M)  
4️⃣ **ACCOUNT** ➝ **DEBIT CARD** → (1:M)  
5️⃣ **DEBIT CARD** ➝ **PLATINUM CARD** → (1:1)  

> **Note**: Platinum Card is a **disjoint** and **partial** subtype of Debit Card.  

---

## 📊 Entity-Relationship (ER) Diagram  
*(Check the project files for the full ER diagram.)*  

---

## 📜 Assumptions & Constraints  
- **Only one auditor** is assigned per bank branch for record consistency.  
- **Only Platinum Cards** are considered as a subtype due to project constraints.  
- **Bank branches manage customer accounts**, not individual employees.  

---

## 📌 How to Use This Repository  
- Review the **ER diagram** to understand relationships.  
- Refer to **business rules** for database constraints.  
- Use **entity descriptions** to structure SQL tables.  

---

## 📜 License  
This project is for academic purposes only.  
  
