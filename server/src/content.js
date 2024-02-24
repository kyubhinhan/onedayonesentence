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
const client_1 = require("@prisma/client");
const router = express_1.default.Router();
const prisma = new client_1.PrismaClient();
// create
router.post('/', function (req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        const { title, author, date, impression } = req.body;
        if (!title || !author || !date || !impression) {
            res.status(400).send('param error');
            return;
        }
        if (!req.userId) {
            res.status(401).send('cannot find userId');
            return;
        }
        const newContent = yield prisma.content.create({
            data: {
                title,
                author,
                date,
                impression,
                userId: Number(req.userId)
            },
        });
        res.status(200).send('ok');
    });
});
// get
router.get('/', function (req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        const { dt } = req.query;
        if (!dt) {
            res.status(400).send('param error');
            return;
        }
        if (!req.userId) {
            res.status(401).send('cannot find userId');
            return;
        }
        const inputDt = new Date(Number(dt));
        const startDt = new Date(inputDt.getFullYear(), inputDt.getMonth(), 1);
        const endDt = new Date(inputDt.getFullYear(), inputDt.getMonth() + 1, 0, 23, 59, 59, 999);
        const content = yield prisma.content.findMany({
            where: {
                AND: [
                    {
                        userId: Number(req.userId)
                    },
                    {
                        date: {
                            gte: startDt.getTime()
                        }
                    },
                    {
                        date: {
                            lte: endDt.getTime()
                        }
                    }
                ]
            }
        });
        res.send(content.map((item) => (Object.assign(Object.assign({}, item), { date: Number(item.date), userId: Number(item.userId) }))).sort((a, b) => b.date - a.date));
    });
});
// update
router.put('/', function (req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        const { id, title, author, date, impression } = req.body;
        if (!id || !title || !author || !date || !impression) {
            res.status(400).send('param error');
            return;
        }
        if (!req.userId) {
            res.status(401).send('cannot find userId');
            return;
        }
        const targetContent = yield prisma.content.findUnique({
            where: {
                id: Number(id)
            }
        });
        if (!targetContent) {
            res.status(400).send('해당하는 대상을 찾을 수 없습니다.');
            return;
        }
        const content = yield prisma.content.update({
            where: {
                id: Number(id)
            },
            data: {
                id: Number(id),
                title,
                author,
                date: Number(date),
                impression,
                userId: Number(req.userId)
            }
        });
        res.send('ok');
    });
});
// delete
router.delete('/', function (req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        const { id } = req.query;
        const content = yield prisma.content.delete({
            where: {
                id: Number(id)
            }
        });
        res.send('ok');
    });
});
exports.default = router;
