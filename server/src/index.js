"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const express_bearer_token_1 = __importDefault(require("express-bearer-token"));
const axios_1 = __importDefault(require("axios"));
const client_1 = require("@prisma/client");
const content_1 = __importDefault(require("@/content"));
const app = (0, express_1.default)();
app.use(express_1.default.json());
app.use((0, express_bearer_token_1.default)());
const kakaoLoginMiddleWare = function (req, res, next) {
    return __awaiter(this, void 0, void 0, function* () {
        const token = req.token;
        const prisma = new client_1.PrismaClient();
        if (!token) {
            res.status(401).send('unAuthorized');
            return;
        }
        const kakaoLoginResponse = yield axios_1.default.get('https://kapi.kakao.com/v2/user/me', {
            headers: {
                "Authorization": `Bearer ${token}`,
                "Content-Type": "application/x-www-form-urlencoded;charset=utf-8"
            }
        });
        if (kakaoLoginResponse.status == 200) {
            const user = yield prisma.user.findUnique({
                where: {
                    id: Number(kakaoLoginResponse.data.id)
                }
            });
            if (!user) {
                yield prisma.user.create({ data: { id: Number(kakaoLoginResponse.data.id) } });
            }
            req.userId = Number(kakaoLoginResponse.data.id);
            next();
        }
        else {
            res.status(401);
            return;
        }
    });
};
app.use(kakaoLoginMiddleWare);
app.use("/content", content_1.default);
app.get('/', (req, res) => {
    res.send('Typescript + Node.js + Express Server');
});
const port = 3000;
app.listen(port, () => {
    console.log(`[server]: Server is running at <http://localhost:${port}>`);
});
