"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
class CustomPrismaClient {
    constructor() {
        // private 생성자로 외부에서 직접 생성을 막음
    }
    static getInstance() {
        if (!CustomPrismaClient.instance) {
            CustomPrismaClient.instance = new client_1.PrismaClient();
        }
        return CustomPrismaClient.instance;
    }
}
CustomPrismaClient.instance = null;
exports.default = CustomPrismaClient;
