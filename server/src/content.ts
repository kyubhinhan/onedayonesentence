import express, { Express, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client'

const router = express.Router()
const prisma = new PrismaClient()

// create
router.post('/', async function (req, res) {
    const { title, author, dt, impression } = req.body;

    const newContent = await prisma.content.create({
        data: {
            title,
            author,
            date: dt,
            impression,
        },
    });

    res.status(200).send('ok');
});

// get
router.get('/', async function (req, res) {
    const { id } = req.query

    const content = await prisma.content.findUnique({
        where: {
            id: Number(id)
        }
    })

    const responseContent = content ? { ...content, date: Number(content.date) } : null

    res.send(responseContent);
});

// update
router.put('/', async function (req, res) {
    const { id, title, author, dt, impression } = req.body;

    const content = await prisma.content.update({
        where: {
            id: Number(id)
        },
        data: {
            title,
            author,
            date: dt,
            impression,
        }
    })

    res.send('ok');
});

// delete
router.delete('/', async function (req, res) {
    const { id } = req.query

    const content = await prisma.content.delete({
        where: {
            id: Number(id)
        }
    })

    res.send('ok');
});

export default router