import { prisma } from "./client.js";

async function main() {
  await prisma.$connect();

  const result = await prisma.$queryRaw<
    { now: Date }[]
  >`SELECT NOW() AS now`;

  console.log("Database connected successfully.");
  console.log("Database time:", result[0]?.now);
}

main()
  .catch((error) => {
    console.error("Database connection failed:");
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });