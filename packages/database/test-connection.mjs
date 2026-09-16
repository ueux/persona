import { prisma } from "./src/client.ts";

try {
  await prisma.$connect();

  const result = await prisma.$queryRaw`SELECT NOW() AS now`;

  console.log("Database connected successfully.");
  console.log("Database time:", result[0]?.now);
} catch (error) {
  console.error("Database connection failed:");
  console.error(error);
  process.exitCode = 1;
} finally {
  await prisma.$disconnect();
}