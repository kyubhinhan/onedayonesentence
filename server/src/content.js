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
        const { title, author, dt, impression } = req.body;
        const newContent = yield prisma.content.create({
            data: {
                title,
                author,
                date: dt,
                impression,
            },
        });
        res.status(200).send('ok');
    });
});
// get
router.get('/', function (req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        const { id } = req.query;
        const content = yield prisma.content.findUnique({
            where: {
                id: Number(id)
            }
        });
        const responseContent = content ? Object.assign(Object.assign({}, content), { date: Number(content.date) }) : null;
        res.send(responseContent);
    });
});
// update
router.put('/', function (req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        const { id, title, author, dt, impression } = req.body;
        const content = yield prisma.content.update({
            where: {
                id: Number(id)
            },
            data: {
                title,
                author,
                date: dt,
                impression,
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
