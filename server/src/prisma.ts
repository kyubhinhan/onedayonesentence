import { PrismaClient } from '@prisma/client'


class CustomPrismaClient {
    private static instance: PrismaClient | null = null;

    private constructor() {
        // private 생성자로 외부에서 직접 생성을 막음
    }

    public static getInstance(): PrismaClient {
        if (!CustomPrismaClient.instance) {
            CustomPrismaClient.instance = new PrismaClient();
        }
        return CustomPrismaClient.instance;
    }
}

export default CustomPrismaClient