import {
  AlertDialog,
  AlertDialogBody,
  AlertDialogContent,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogOverlay,
  Box,
  Button,
  Icon,
  Stack,
  Text,
  useDisclosure,
  useToast,
} from "@chakra-ui/react";
import { IoCalendarClearOutline } from "react-icons/io5";
import { LuClock } from "react-icons/lu";
import { MdOutlinePersonOutline } from "react-icons/md";
import { Course } from "../../../models/models";

import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { axiosInstance } from "../../../api/axiosInstance";
import { useRef } from "react";

const AdminCourseBox = (props: Course) => {
  const { t } = useTranslation();
  const {
    isOpen: isDeleteCourseConfirmOpen,
    onOpen: onOpenDeleteCourseConfirm,
    onClose: onCloseDeleteCourseConfirm,
  } = useDisclosure();
  const toast = useToast();
  const cancelRef = useRef(null);
  const queryClient = useQueryClient();
  const deleteCourseMutation = useMutation({
    mutationFn: () => {
      return axiosInstance.delete(`/courses/remove/${props.course_id}`);
    },
    onSuccess: (res) => {
      onCloseDeleteCourseConfirm();
      queryClient.invalidateQueries({ queryKey: ["total-courses"] });
      toast({
        title: "Course Deleted!",
        description: `course deleted with id of ${res.data.course.course_id}`,
        status: "success",
        duration: 3000,
      });
    },
  });

  const formatDays = (days: string[]): string => {
    let formattedDays = "";
    days.forEach((day) => (formattedDays += `${t(day.toLowerCase())} - `));
    return formattedDays.substring(0, formattedDays.length - 2);
  };

  return (
    <>
      <Box borderRadius="15px" bg="#F3F4FF" padding="20px">
        <Text fontSize="lg">{props.name}</Text>
        <Stack mt="20px">
          <Text>
            <Icon as={MdOutlinePersonOutline} /> {props.professor}
          </Text>
          <Text>
            <Icon as={IoCalendarClearOutline} /> {formatDays(props.days)}
          </Text>
          <Text>
            <Icon as={LuClock} />{" "}
            <Text display="inline" dir="ltr">
              {props.time}
            </Text>
          </Text>
        </Stack>
        <Button onClick={onOpenDeleteCourseConfirm} variant="ghost" color="red">
          {t("deleteCourse")}
        </Button>
      </Box>

      {isDeleteCourseConfirmOpen && (
        <AlertDialog
          isCentered
          isOpen={isDeleteCourseConfirmOpen}
          leastDestructiveRef={cancelRef}
          onClose={onCloseDeleteCourseConfirm}
        >
          <AlertDialogOverlay>
            <AlertDialogContent>
              <AlertDialogHeader fontSize="lg" fontWeight="bold">
                {t("deleteCourse")}
              </AlertDialogHeader>

              <AlertDialogBody>
                {t("deleteCourseConfirmMessage")}
              </AlertDialogBody>

              <AlertDialogFooter>
                <Button ref={cancelRef} onClick={onCloseDeleteCourseConfirm}>
                  {t("cancel")}
                </Button>
                <Button
                  colorScheme="red"
                  onClick={() => {
                    deleteCourseMutation.mutate();
                  }}
                  marginStart={3}
                >
                  {t("delete")}
                </Button>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialogOverlay>
        </AlertDialog>
      )}
    </>
  );
};

export default AdminCourseBox;
