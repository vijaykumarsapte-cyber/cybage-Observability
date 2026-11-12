# FROM node:18

# WORKDIR /app

# COPY package*.json ./
# RUN npm install

# COPY . .

# RUN npx prisma generate

# EXPOSE 5000

# CMD ["sh", "-c", "npx prisma migrate deploy && node index.js"]

FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npx prisma generate

EXPOSE 5000

# ✅ FIX: create tables automatically before starting app
CMD ["sh", "-c", "npx prisma db push && node index.js"]